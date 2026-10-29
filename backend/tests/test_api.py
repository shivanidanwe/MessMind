import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["app_name"] == "MessMind API"

def test_login_success():
    response = client.post("/api/v1/auth/login", json={
        "email": "admin@messmind.com",
        "password": "AdminPassword123!"
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["role"] == "ADMIN"

def test_login_invalid_password():
    response = client.post("/api/v1/auth/login", json={
        "email": "admin@messmind.com",
        "password": "WrongPassword!"
    })
    assert response.status_code == 401

def test_authenticated_me_and_dashboard():
    # Login as Manager
    login_res = client.post("/api/v1/auth/login", json={
        "email": "manager@messmind.com",
        "password": "ManagerPassword123!"
    })
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # /me
    me_res = client.get("/api/v1/auth/me", headers=headers)
    assert me_res.status_code == 200
    assert me_res.json()["email"] == "manager@messmind.com"

    # Dashboard Summary
    dash_res = client.get("/api/v1/dashboard/summary", headers=headers)
    assert dash_res.status_code == 200
    dash_data = dash_res.json()
    assert "active_users" in dash_data
    assert "today_scheduled_meals" in dash_data

    # Menus
    menu_res = client.get("/api/v1/menus", headers=headers)
    assert menu_res.status_code == 200
    assert len(menu_res.json()) > 0

    # Ingredients
    ing_res = client.get("/api/v1/ingredients", headers=headers)
    assert ing_res.status_code == 200
    assert len(ing_res.json()) > 0

    # Waste Records
    waste_res = client.get("/api/v1/waste-records", headers=headers)
    assert waste_res.status_code == 200

    # Reports export
    report_res = client.get("/api/v1/reports/export?report_type=consumption", headers=headers)
    assert report_res.status_code == 200
    assert "Prepared Qty" in report_res.text
