from flask import Blueprint
from flask_jwt_extended import jwt_required
from app.services.analytics_service import dashboard_summary
from app.utils.response import success_response


dashboard_bp = Blueprint("dashboard", __name__, url_prefix="/api")


@dashboard_bp.get("/dashboard")
@jwt_required()
def protected_dashboard():
    return success_response(dashboard_summary(), "Protected dashboard data")
