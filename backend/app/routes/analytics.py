from flask import Blueprint
from flask_jwt_extended import jwt_required
from app.services.analytics_service import (
    dashboard_summary,
    studies_by_status,
    participants_by_disease,
    experiments_by_type,
    top_biomarkers,
    research_activity_over_time,
)
from app.utils.response import success_response


analytics_bp = Blueprint("analytics", __name__, url_prefix="/api/analytics")


@analytics_bp.get("/dashboard")
@jwt_required()
def dashboard_metrics():
    return success_response(dashboard_summary())


@analytics_bp.get("/studies-by-status")
@jwt_required()
def studies_status():
    return success_response(studies_by_status())


@analytics_bp.get("/participants-by-disease")
@jwt_required()
def participants_disease():
    return success_response(participants_by_disease())


@analytics_bp.get("/experiments-by-type")
@jwt_required()
def experiments_type():
    return success_response(experiments_by_type())


@analytics_bp.get("/top-biomarkers")
@jwt_required()
def top_biomarkers_route():
    return success_response(top_biomarkers())


@analytics_bp.get("/research-activity-over-time")
@jwt_required()
def research_activity_route():
    return success_response(research_activity_over_time())
