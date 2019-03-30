from server.models.post import Post
from server.utils import bad_request
from . import bp
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_current_user
from server.models.group import Group
from server import db


'''
Create Post
'''


@bp.route("/<int:group_id>/posts/create", methods=["POST"])
@jwt_required
def create_post(group_id):
    # noinspection PyBroadException
    try:
        data = request.get_json()
        title = data["title"]
        description = data["description"]
        if not isinstance(title, str) or not isinstance(description, str):
            raise Exception
    except:
        return bad_request("Invalid request")

    user = get_current_user()
    if not user:
        return bad_request("invalid_token", 401)
    group = Group.query.get(group_id)
    if not group:
        return "", 404

    post = Post(title=title, description=description, group=group, creator=user)
    db.session.commit()
    res = post.as_dict()
    return jsonify(res), 201


'''
List Posts
'''


@bp.route("/<int:group_id>/posts", methods=["GET"])
@jwt_required
def list_posts(group_id):

    group = Group.query.get(group_id)
    if not group:
        return "", 404

    posts = group.posts.order_by(Post.created_at).all()
    return jsonify({
        "group-id": group_id,
        "posts": [p.as_dict() for p in posts]
    }), 200
