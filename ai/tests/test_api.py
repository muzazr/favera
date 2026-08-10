from fastapi.testclient import TestClient

from app.main import app


def test_health_endpoint():
    client = TestClient(app)
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_evaluate_batch_endpoint():
    client = TestClient(app)
    payload = {
        "request_id": "req_api_batch_01",
        "user_id": "usr_001",
        "current_transactions": [
            {
                "transaction_id": "txn_001",
                "transaction_at": "2026-08-02T10:00:00+07:00",
                "amount": 500000.0,
                "counterparty_id": "rcp_001",
                "direction": "transfer",
            }
        ],
        "historical_transactions": [],
    }

    response = client.post("/v1/model1/evaluate-batch", json=payload)
    assert response.status_code == 200
    res_data = response.json()
    assert res_data["request_id"] == "req_api_batch_01"
    assert len(res_data["assessments"]) == 1
    assessment = res_data["assessments"][0]
    assert assessment["transaction_id"] == "txn_001"
    assert assessment["risk_band"] in ("normal", "unusual", "needs_confirmation")
    assert assessment["personal_baseline_status"] == "insufficient_history"
    assert assessment["personal_model_score"] is None


def test_evaluate_single_endpoint():
    client = TestClient(app)
    payload = {
        "request_id": "req_api_single_01",
        "user_id": "usr_001",
        "transaction": {
            "transaction_id": "txn_001",
            "timestamp": "2026-08-02T10:00:00+07:00",
            "amount": 500000.0,
            "recipient_id": "rcp_001",
            "direction": "transfer",
        },
        "history": [],
    }

    response = client.post("/v1/model1/evaluate", json=payload)
    assert response.status_code == 200
    res_data = response.json()
    assert res_data["request_id"] == "req_api_single_01"
    assert "attention_score" in res_data
    assert "component_scores" in res_data
    assert res_data["component_scores"]["global_score"] is None or isinstance(
        res_data["component_scores"]["global_score"], float
    )


def test_evaluate_single_endpoint_canonical_fields():
    client = TestClient(app)
    payload = {
        "request_id": "req_api_single_02",
        "user_id": "usr_001",
        "transaction": {
            "transaction_id": "txn_002",
            "transaction_at": "2026-08-02T10:00:00+07:00",
            "amount": 500000.0,
            "counterparty_id": "rcp_001",
            "direction": "transfer",
        },
        "history": [],
    }

    response = client.post("/v1/model1/evaluate", json=payload)
    assert response.status_code == 200
    res_data = response.json()
    assert res_data["request_id"] == "req_api_single_02"


