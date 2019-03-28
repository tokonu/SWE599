from server import db, ma
from server.utils import timestamp


class Tag(db.Model):
    __tablename__ = "tags"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), nullable=False, unique=True)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)


class TagSchema(ma.ModelSchema):
    class Meta:
        model = Tag
        fields = ("name",)


# tag_schema = TagSchema()
# tags_schema = TagSchema(many=True)
