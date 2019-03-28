from server.utils import bad_request
from . import bp
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_current_user
from server.models.tag import Tag
from server.models.group import Group
from server import db
from sqlalchemy import or_

'''
Create Group
'''


@bp.route("/create", methods=["POST"])
@jwt_required
def create_group():
    # noinspection PyBroadException
    try:
        data = request.get_json()
        name = data["name"]
        tags = data.get("tags", [])
        for t in tags:
            if not isinstance(t, str):
                raise Exception
        if not isinstance(name, str):
            raise Exception
    except:
        return bad_request("Invalid request")

    if Group.query.filter_by(name=name).first():
        return bad_request("Duplicate group name")

    user = get_current_user()
    group = Group(name=name, creator=user)
    db.session.add(group)
    user.groups.append(group)

    tag_objs = Tag.query.filter(Tag.name.in_(tags))
    for to in tag_objs:
        tags.remove(to.name)
        group.tags.append(to)

    for tag in tags:
        t = Tag(name=tag)
        db.session.add(t)
        group.tags.append(t)

    db.session.commit()

    return jsonify(group.as_dict()), 201


''' Join Group '''


@bp.route("/<int:group_id>/join", methods=["POST"])
@jwt_required
def join_group(group_id):
    user = get_current_user()

    if not user:
        return bad_request("invalid_token", 401)

    # already joined
    if user.groups.filter_by(id=group_id).first():
        return "", 200

    group = Group.query.get(group_id)

    if not group:
        return "", 404

    user.groups.append(group)
    db.session.commit()
    return "", 200


''' Leave Group '''


@bp.route("/<int:group_id>/leave", methods=["POST"])
@jwt_required
def leave_group(group_id):
    user = get_current_user()

    if not user:
        return bad_request("invalid_token", 401)

    group = user.groups.filter_by(id=group_id).first()

    if not group:
        return "", 200

    user.groups.remove(group)
    db.session.commit()
    return "", 200


''' Search Group '''


@bp.route("/search", methods=["GET"])
@jwt_required
def search_group():
    search_query = request.args.get("q", "")
    result = []
    groups = Group.query.filter(or_(
        Group.name.like("%{}%".format(search_query)),
        Group.tags.any(Tag.name.like("%{}%".format(search_query)))
    )).all()
    for group in groups:
        result.append(group.as_dict())
    return jsonify({
        "query": search_query,
        "groups": result
    }), 200
