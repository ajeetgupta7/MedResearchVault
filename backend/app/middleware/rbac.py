from functools import wraps
from flask_jwt_extended import get_jwt, verify_jwt_in_request
from app.utils.response import error_response


def roles_required(*allowed_roles):
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            verify_jwt_in_request()
            claims = get_jwt()
            role = claims.get("role")
            if role not in allowed_roles:
                return error_response("Insufficient permissions", 403)
            return fn(*args, **kwargs)

        return wrapper

    return decorator
