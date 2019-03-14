import time
import re
from flask import jsonify


def timestamp():
    """Return the current timestamp as an integer."""
    return int(time.time())


def bad_request(message, status=400):
    response = jsonify({'message': message})
    response.status_code = status
    return response


EMAIL_REGEX = re.compile(r"^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")


def is_email_valid(email):
    return EMAIL_REGEX.match(email)
