from flask import Blueprint, request
from flask_jwt_extended import create_access_token
from werkzeug.security import check_password_hash
from app.models.models import User
from app.utils.response import success_response, error_response


auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")


@auth_bp.post("/login")
def login():
    payload = request.get_json(silent=True) or {}
    username = payload.get("username", "").strip()
    password = payload.get("password", "")

    if not username or not password:
        return error_response("Username and password are required", 400)

    user = User.query.filter_by(username=username, is_active=True).first()
    if not user or not check_password_hash(user.password_hash, password):
        return error_response("Invalid credentials", 401)

    token = create_access_token(identity=str(user.user_id), additional_claims={"role": user.role.role_name})
    return success_response(
        {
            "token": token,
            "user": {
                "user_id": user.user_id,
                "username": user.username,
                "email": user.email,
                "role": user.role.role_name,
            },
        },
        "Login successful",
    )
