from marshmallow import fields

from server import db, ma
from server.utils import timestamp


class Message(db.Model):
    __tablename__ = "messages"
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(64), nullable=False)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    post_id = db.Column(db.Integer, db.ForeignKey('posts.id'), nullable=False)

    def as_dict(self):
        return message_schema.dump(self).data


class MessageSchema(ma.ModelSchema):
    class Meta:
        model = Message
        fields = ("id", "text", "created_at", "post_id", "creator_id")
    created_at = fields.Number(dump_to="created-at")
    post_id = fields.Number(dump_to="post-id")
    creator_id = fields.Number(dump_to="creator-id")


message_schema = MessageSchema()
