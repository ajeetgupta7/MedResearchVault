from flask import Flask
from flask_cors import CORS
from app.config import Config
from app.extensions import db, jwt
from app.middleware.error_handlers import register_error_handlers
from app.routes import register_routes


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    CORS(app, resources={r"/api/*": {"origins": "*"}})
    db.init_app(app)
    jwt.init_app(app)

    register_routes(app)
    register_error_handlers(app)

    @app.get("/health")
    def health():
        return {"status": "ok", "service": "MedResearchVault API"}

    return app
