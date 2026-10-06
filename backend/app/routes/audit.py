from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from app.models.models import AuditLog
from app.services.crud_service import model_to_dict
from app.utils.response import success_response


audit_bp = Blueprint("audit", __name__, url_prefix="/api/audit-logs")


@audit_bp.get("")
@jwt_required()
def list_audit_logs():
    page = request.args.get("page", default=1, type=int)
    per_page = request.args.get("per_page", default=25, type=int)
    pagination = AuditLog.query.order_by(AuditLog.changed_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    return success_response(
        {
            "items": [model_to_dict(item) for item in pagination.items],
            "pagination": {
                "page": pagination.page,
                "per_page": pagination.per_page,
                "total": pagination.total,
                "pages": pagination.pages,
            },
        }
    )
