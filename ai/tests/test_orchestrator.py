from app.fusion import FusionEngine
from app.global_ranker import FixedGlobalRanker, NullGlobalRanker
from app.orchestrator import Model1Orchestrator
from app.personal_anomaly import PersonalAnomalyScorer
from app.rule_engine import RuleEngine


def _history():
    return [
        {
            "transaction_at": f"2026-08-01T{8 + index:02d}:00:00+07:00",
            "amount": 50_000,
            "counterparty_id": "known-recipient",
        }
        for index in range(8)
    ]


def _transaction():
    return {
        "transaction_id": "txn-test",
        "transaction_at": "2026-08-02T17:00:00+07:00",
        "amount": 900_000,
        "counterparty_id": "new-recipient",
        "balance_before": 1_000_000,
        "balance_after": 100_000,
    }


def test_orchestrator_returns_complete_contract():
    orchestrator = Model1Orchestrator(
        global_ranker=FixedGlobalRanker(probability=0.95, percentile=0.997),
        personal_anomaly=PersonalAnomalyScorer(),
        rule_engine=RuleEngine(),
        fusion_engine=FusionEngine(),
    )

    result = orchestrator.evaluate(
        request_id="req-test",
        user_id="user-test",
        transaction=_transaction(),
        history=_history(),
    )

    assert result["request_id"] == "req-test"
    assert result["transaction_id"] == "txn-test"
    assert 0.0 <= result["attention_score"] <= 1.0
    assert set(result["components"]) == {"global", "personal", "rules", "fusion"}
    assert result["processing"]["status"] == "success"
    assert isinstance(result["reason_codes"], list)


def test_orchestrator_assess_batch_returns_openapi_contract():
    orchestrator = Model1Orchestrator(
        global_ranker=FixedGlobalRanker(probability=0.95, percentile=0.997),
        personal_anomaly=PersonalAnomalyScorer(),
        rule_engine=RuleEngine(),
        fusion_engine=FusionEngine(),
    )

    payload = {
        "request_id": "req-batch-001",
        "user_id": "user-001",
        "current_transactions": [_transaction()],
        "historical_transactions": _history(),
    }

    result = orchestrator.assess_batch(payload)

    assert result["request_id"] == "req-batch-001"
    assert isinstance(result["assessments"], list)
    assert len(result["assessments"]) == 1
    assessment = result["assessments"][0]
    assert assessment["transaction_id"] == "txn-test"
    assert assessment["risk_band"] in ("normal", "unusual", "needs_confirmation")
    assert assessment["personal_baseline_status"] == "available"
    assert isinstance(result["processing_ms"], float)


def test_orchestrator_still_works_without_global_artifact():
    orchestrator = Model1Orchestrator(
        global_ranker=NullGlobalRanker(),
        personal_anomaly=PersonalAnomalyScorer(),
        rule_engine=RuleEngine(),
        fusion_engine=FusionEngine(),
    )

    result = orchestrator.evaluate(
        transaction=_transaction(),
        history=_history(),
    )

    assert result["components"]["global"]["status"] == "unavailable"
    assert 0.0 <= result["attention_score"] <= 1.0


def test_batch_assessment_order_and_temporal_safety():
    orchestrator = Model1Orchestrator(
        global_ranker=NullGlobalRanker(),
        personal_anomaly=PersonalAnomalyScorer(),
        rule_engine=RuleEngine(),
        fusion_engine=FusionEngine(),
    )

    # Input has reverse chronological order in current_transactions
    txn_later = {
        "transaction_id": "txn_later",
        "transaction_at": "2026-08-02T12:00:00+07:00",
        "amount": 500_000,
        "counterparty_id": "rcp_a",
    }
    txn_earlier = {
        "transaction_id": "txn_earlier",
        "transaction_at": "2026-08-02T10:00:00+07:00",
        "amount": 100_000,
        "counterparty_id": "rcp_b",
    }
    txn_same_ts = {
        "transaction_id": "txn_same",
        "transaction_at": "2026-08-02T10:00:00+07:00",
        "amount": 200_000,
        "counterparty_id": "rcp_c",
    }
    future_history = {
        "transaction_id": "hist_future",
        "transaction_at": "2026-08-05T00:00:00+07:00",
        "amount": 999_999,
        "counterparty_id": "rcp_future",
    }

    payload = {
        "request_id": "req-batch-temporal",
        "user_id": "user-temporal",
        "current_transactions": [txn_later, txn_earlier, txn_same_ts],
        "historical_transactions": _history() + [future_history],
    }

    result = orchestrator.assess_batch(payload)

    # 1. Response order matches request order (txn_later, txn_earlier, txn_same_ts)
    assert [a["transaction_id"] for a in result["assessments"]] == [
        "txn_later",
        "txn_earlier",
        "txn_same",
    ]
    # 2. No transaction lost
    assert len(result["assessments"]) == 3
    # 3. Global model score is None when global ranker is NullGlobalRanker
    for assessment in result["assessments"]:
        assert assessment["global_model_score"] is None


def test_cold_start_behavior():
    from app.factory import assess_batch

    payload = {
        "request_id": "req-cold-start",
        "user_id": "user-cold",
        "current_transactions": [
            {
                "transaction_id": "txn_cold",
                "transaction_at": "2026-08-02T10:00:00+07:00",
                "amount": 500_000,
                "counterparty_id": "rcp_cold",
            }
        ],
        "historical_transactions": [
            {
                "transaction_at": "2026-08-01T10:00:00+07:00",
                "amount": 50_000,
            }
        ],  # Only 1 historical transaction (< 8)
    }

    result = assess_batch(payload)
    assessment = result["assessments"][0]

    assert assessment["personal_baseline_status"] == "insufficient_history"
    assert assessment["personal_model_score"] is None
    assert "LIMITED_USER_HISTORY" in assessment["reason_codes"]


