from server import socketio, db
from flask_socketio import emit, join_room, leave_room
from time import sleep
from flask_jwt_extended import get_current_user, verify_jwt_in_request_optional

from server.models.message import Message


def ack(data):
    print("ack "+str(data))


@socketio.on("connect")
def connect():
    verify_jwt_in_request_optional()  # required when jwt is used without decorators
    if not get_current_user():
        return False
    print("client connected")
    sleep(2)
    emit("deneme", {"data": "a"}, callback=ack)


@socketio.on("join_post")
def join_post(post_id):
    print("joined post "+str(post_id))
    join_room(str(post_id))


@socketio.on("leave_post")
def leave_post(post_id):
    print("left post "+str(post_id))
    leave_room(str(post_id))


@socketio.on("send_message")
def send_message(data):
    verify_jwt_in_request_optional()
    user = get_current_user()
    text = data["text"]
    post_id = data["post-id"]
    if not user or not text or not post_id:
        print("invalid send message event")
        return
    message = Message(text=text, creator_id=user.id, post_id=post_id)
    db.session.add(message)
    db.session.commit()
    emit("new_message", message.as_dict(), room=str(post_id))


# @socketio.on('disconnect', namespace='/chat')
# def test_disconnect():
#     print('Client disconnected')

