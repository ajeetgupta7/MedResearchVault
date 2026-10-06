from app.routes.auth import auth_bp
from app.routes.crud import crud_bp
from app.routes.analytics import analytics_bp
from app.routes.audit import audit_bp
from app.routes.search import search_bp
from app.routes.reports import reports_bp
from app.routes.dbms import dbms_bp
from app.routes.dashboard import dashboard_bp


def register_routes(app):
    app.register_blueprint(auth_bp)
    app.register_blueprint(crud_bp)
    app.register_blueprint(analytics_bp)
    app.register_blueprint(audit_bp)
    app.register_blueprint(search_bp)
    app.register_blueprint(reports_bp)
    app.register_blueprint(dbms_bp)
    app.register_blueprint(dashboard_bp)
