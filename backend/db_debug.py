from server import create_app, db
from server.models.group import Group
from server.models.user import User
from server.models.tag import Tag
from server.models.post import Post


app = create_app()
app.app_context().push()

