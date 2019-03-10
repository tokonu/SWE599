Requirements v1.0

## Functional Requirements

1. User Account Operations
    1. User shall provide their email and password while creating a new account.
    2. User shall login to their account using email and password.
    3. User shall be able to update their password.
    4. User shall be able to reset their password by using their email address.
2. Group Operations
    1. User shall be able to list groups that they joined.
    2. User shall be able to search available groups by name and tags.
    3. User shall be able to join any group.
    4. User shall be able to leave a previously joined group.
    5. User shall be able to create a group by providing a unique name and optional tags.
3. Post Operations
    1. User shall be able to create posts in groups they previously joined.
    2. User shall enter a title and description to create a post.
    3. User shall be able to list posts belonging to a group.
    4. Every post shall include a message thread.
    5. User shall be able to send a message to any post that belongs to a group that the user joined.


## Non-functional requirements

1. The backend system shall run on a unix based operating system such as Ubuntu.
2. The backend system shall be developed with python language and flask web framework.
3. Gunicorn shall be used as python http server.
4. The backend system shall be deployed with Docker.
5. The client system shall be an iphone application that is compatible with ios 11 and up.
6. The client system shall be developed using swift programming language.
7. The system shall use and contain only open source technologies, libraries, and tools.
8. The backend system shall expose an HTTP RESTful API.
9. Every operation (except login/signup/forgot password) shall require authentication.