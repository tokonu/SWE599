from server import db, ma
from server.utils import timestamp


group_tag_table = \
    db.Table('group_tag',
             db.Column('group_id', db.Integer, db.ForeignKey('groups.id'), primary_key=True),
             db.Column('tag_id', db.Integer, db.ForeignKey('tags.id'), primary_key=True)
             )


class Group(db.Model):
    __tablename__ = "groups"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), nullable=False, unique=True)
    created_at = db.Column(db.Integer, default=timestamp)
    updated_at = db.Column(db.Integer, default=timestamp, onupdate=timestamp)
    creator_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    posts = db.relationship('Post', backref="group", lazy="dynamic")
    tags = db.relationship('Tag', secondary=group_tag_table, backref=db.backref('groups', lazy="dynamic"))

    def as_dict(self):
        d = group_schema.dump(self).data
        d["tags"] = [t.name for t in self.tags]
        return d


class GroupSchema(ma.ModelSchema):
    class Meta:
        model = Group
        fields = ("id", "name")


group_schema = GroupSchema()
groups_schema = GroupSchema(many=True)
