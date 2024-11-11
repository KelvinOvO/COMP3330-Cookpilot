// lib/pages/recipe_detail_page.dart
import 'package:app_controller_client/app_controller_client.dart';
import 'package:built_collection/built_collection.dart';
import 'package:cookpilot/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../global/app_controller.dart';
import '../models/comment.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

enum _ChatMessageRole {
  user,
  assistant,
  error,
}

class _ChatMessage {
  final String text;
  final _ChatMessageRole role;

  _ChatMessage({
    required this.text,
    required this.role,
  });
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  static const double _kSpacing = 16.0;
  static const double _kBorderRadius = 12.0;

  final TextEditingController _chatController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late final ValueNotifier<List<_ChatMessage>> _chatMessages = ValueNotifier([
    _ChatMessage(
      text:
          'Hello! I am Cookpilot, your recipe assistant. How can I help you today?',
      role: _ChatMessageRole.assistant,
    )
  ]);
  bool _isCommentExpanded = false;

  @override
  void dispose() {
    _chatController.dispose();
    _chatFocusNode.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _chatMessages.dispose();
    super.dispose();
  }

  void _handleChatSend() async {
    if (_chatController.text.trim().isEmpty) return;

    _chatMessages.value = [
      ..._chatMessages.value,
      _ChatMessage(
        text: _chatController.text,
        role: _ChatMessageRole.user,
      ),
    ];

    _chatController.clear();

    try {
      final requestMessages = _chatMessages.value
          .where((message) => message.role != _ChatMessageRole.error)
          .map((message) => (ChatByRecipeMessageModelBuilder()
                ..role = switch (message.role) {
                  _ChatMessageRole.user => ChatByRecipeRoleModel.user,
                  _ChatMessageRole.assistant => ChatByRecipeRoleModel.assistant,
                  _ChatMessageRole.error => throw Exception('Invalid role'),
                }
                ..text = message.text)
              .build())
          .toList();

      final api = appController.getRecipeSearchApi();
      final chatResponse = await api.recipeSearchChatByRecipePost(
          chatByRecipePostRequestModel: (ChatByRecipePostRequestModelBuilder()
                ..id = widget.recipe.id
                ..messages = ListBuilder(requestMessages))
              .build());

      if (!mounted) {
        return;
      }

      final responseMessage = chatResponse.data!.message;
      _chatMessages.value = [
        ..._chatMessages.value,
        _ChatMessage(
          text: responseMessage.text,
          role: _ChatMessageRole.assistant,
        ),
      ];
    } catch (e) {
      print(e);

      if (!mounted) {
        return;
      }

      _chatMessages.value = [
        ..._chatMessages.value,
        _ChatMessage(
          text:
              'An error occurred, I am sincerely sorry for not being able to process your request.',
          role: _ChatMessageRole.error,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              _buildContent(context),
              const SliverToBoxAdapter(
                child: SizedBox(height: 72),
              ),
            ],
          ),
          if (MediaQuery.of(context).viewInsets.bottom > 0)
            const SizedBox()
          else
            Positioned(
              left: _kSpacing,
              right: _kSpacing,
              bottom: _kSpacing,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(_kBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kBorderRadius),
                      ),
                    ),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showModalBottomSheet(
                        context: context,
                        builder: _buildChat,
                        showDragHandle: true,
                        isScrollControlled: true,
                        useSafeArea: true,
                      );
                    },
                    child: const Text(
                      'Chat with Cookpilot for more...',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChat(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(_kSpacing, 0, _kSpacing, _kSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessageList(),
          TextField(
            controller: _chatController,
            focusNode: _chatFocusNode,
            autofocus: true,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Chat with Cookpilot for more...',
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _handleChatSend,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_kBorderRadius),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                  width: 1,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_kBorderRadius),
                borderSide: BorderSide(
                  color: theme.primaryColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: _kSpacing,
                vertical: _kSpacing / 2,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'post_image_${widget.recipe.imageUrl}',
          child: CachedNetworkImage(
            imageUrl: widget.recipe.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error_outline),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorSection(),
          _buildTitleSection(),
          _buildPostContent(),
          _buildInteractionSection(),
          _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ValueListenableBuilder<List<_ChatMessage>>(
      valueListenable: _chatMessages,
      builder: (context, messages, child) {
        final theme = Theme.of(context);

        return Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: _kSpacing),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages.reversed.toList()[index];
              final isUserMessage = message.role == _ChatMessageRole.user;
              final isAssistantMessage =
                  message.role == _ChatMessageRole.assistant;
              final isErrorMessage = message.role == _ChatMessageRole.error;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUserMessage
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isUserMessage)
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            Image.asset('assets/icons/default.png').image,
                      ),
                    const SizedBox(width: _kSpacing / 1.2),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          color: isUserMessage
                              ? theme.colorScheme.surface
                              : isAssistantMessage
                                  ? theme.primaryColor.withOpacity(0.05)
                                  : isErrorMessage
                                      ? theme.colorScheme.error
                                          .withOpacity(0.05)
                                      : Colors.grey[50],
                          borderRadius: BorderRadius.circular(_kBorderRadius),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isUserMessage
                                ? theme.colorScheme.onSurface
                                : isAssistantMessage
                                    ? theme.primaryColor
                                    : isErrorMessage
                                        ? theme.colorScheme.error
                                        : Colors.grey[900],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: _kSpacing / 1.2),
                    if (isUserMessage)
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://i.pravatar.cc/100?u=current_user',
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAuthorSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Hero(
            tag: 'author_avatar_${widget.recipe.author}',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: 'https://i.pravatar.cc/100?u=${widget.recipe.id}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipe.author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getTimeAgo(widget.recipe.publishDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.recipe.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          ...widget.recipe.ingredients.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          const Text(
            'Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          ...widget.recipe.instructions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInteractionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInteractionButton(
            Icons.favorite_border,
            '${widget.recipe.likes}',
            Colors.red[400]!,
          ),
          _buildInteractionButton(
            Icons.star_border,
            'Favorite',
            Colors.orange,
          ),
          _buildInteractionButton(
            Icons.share_outlined,
            'Share',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    final hasMoreComments = widget.recipe.comments.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments (${widget.recipe.comments.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (hasMoreComments)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCommentExpanded = !_isCommentExpanded;
                    });
                  },
                  icon: Icon(
                    _isCommentExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(
                    _isCommentExpanded ? 'Show Less' : 'Show All',
                  ),
                ),
            ],
          ),
        ),
        _buildCommentInput(),
        _buildCommentList(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              'https://i.pravatar.cc/100?u=current_user',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                // TODO: Implement comment submission
                _commentController.clear();
              }
            },
            icon: const Icon(Icons.comment_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    final comments = widget.recipe.comments;
    final displayComments =
        _isCommentExpanded ? comments : comments.take(2).toList();

    return Column(
      children: [
        ...displayComments.map((comment) => _buildCommentItem(comment)),
        if (!_isCommentExpanded && comments.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isCommentExpanded = true;
                });
              },
              child: Text('View ${comments.length - 2} more comments'),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: comment.replies.isEmpty ? 16 : 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(comment.userAvatar),
                radius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border, size: 16),
                          label: Text('${comment.likes}'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text('Reply'),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map(
              (reply) => Padding(
                padding: const EdgeInsets.only(left: 44),
                child: _buildCommentItem(reply),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return dateTime.toString().substring(0, 10);
    }
  }
}
