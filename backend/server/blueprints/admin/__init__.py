from flask_admin.contrib.sqla import ModelView
from server.models.user import User
from server import db


class UserModelView(ModelView):
    column_exclude_list = ['password_hash', ]
    column_searchable_list = ['email']

    def is_accessible(self):
        # todo implement admin auth
        return True


user_model_view = UserModelView(model=User, session=db.session)
