from sqlalchemy.exc import SQLAlchemyError
from app.utils.response import error_response


def register_error_handlers(app):
    @app.errorhandler(404)
    def not_found(_):
        return error_response("Resource not found", 404)

    @app.errorhandler(400)
    def bad_request(_):
        return error_response("Invalid request", 400)

    @app.errorhandler(SQLAlchemyError)
    def db_error(err):
        app.logger.exception("Database error: %s", err)
        return error_response("Database operation failed", 500)

    @app.errorhandler(Exception)
    def general_error(err):
        app.logger.exception("Unhandled error: %s", err)
        return error_response("Unexpected server error", 500)
