from __future__ import annotations

import json
from app.factory import assess_batch


def run_smoke_test():
    history_8 = [
        {
            "transaction_id": f"hist_{i}",
            "transaction_at": f"2026-08-01T{8 + i:02d}:00:00+07:00",
            "amount": 50_000.0,
            "counterparty_id": "known_recipient_01",
            "direction": "expense",
            "balance_before": 2_000_000.0,
            "balance_after": 1_950_000.0,
        }
        for i in range(8)
    ]

    scenarios = [
        {
            "name": "1. Transaksi biasa dengan histori cukup",
            "current": [
                {
                    "transaction_id": "scen_1_normal",
                    "transaction_at": "2026-08-02T10:00:00+07:00",
                    "amount": 50_000.0,
                    "counterparty_id": "known_recipient_01",
                    "direction": "expense",
                    "balance_before": 2_000_000.0,
                    "balance_after": 1_950_000.0,
                }
            ],
            "history": history_8,
        },
        {
            "name": "2. Nominal jauh di atas baseline personal",
            "current": [
                {
                    "transaction_id": "scen_2_high_amount",
                    "transaction_at": "2026-08-02T11:00:00+07:00",
                    "amount": 2_000_000.0,
                    "counterparty_id": "known_recipient_01",
                    "direction": "transfer",
                    "balance_before": 5_000_000.0,
                    "balance_after": 3_000_000.0,
                }
            ],
            "history": history_8,
        },
        {
            "name": "3. Penerima baru",
            "current": [
                {
                    "transaction_id": "scen_3_new_recipient",
                    "transaction_at": "2026-08-02T12:00:00+07:00",
                    "amount": 300_000.0,
                    "counterparty_id": "new_recipient_xyz",
                    "direction": "transfer",
                    "balance_before": 2_000_000.0,
                    "balance_after": 1_700_000.0,
                }
            ],
            "history": history_8,
        },
        {
            "name": "4. Transaksi besar berdampak besar pada saldo",
            "current": [
                {
                    "transaction_id": "scen_4_large_impact",
                    "transaction_at": "2026-08-02T13:00:00+07:00",
                    "amount": 900_000.0,
                    "counterparty_id": "known_recipient_01",
                    "direction": "transfer",
                    "balance_before": 1_000_000.0,
                    "balance_after": 100_000.0,
                }
            ],
            "history": history_8,
        },
        {
            "name": "5. Cold-start",
            "current": [
                {
                    "transaction_id": "scen_5_cold_start",
                    "transaction_at": "2026-08-02T14:00:00+07:00",
                    "amount": 100_000.0,
                    "counterparty_id": "recipient_cold",
                    "direction": "expense",
                    "balance_before": 1_000_000.0,
                    "balance_after": 900_000.0,
                }
            ],
            "history": history_8[:1],  # Only 1 transaction history
        },
    ]

    print("================================================================================")
    print("FAVERA MODEL 1 INFERENCE - SMOKE TEST RESULTS")
    print("================================================================================\n")

    all_results = []

    for index, scen in enumerate(scenarios, start=1):
        payload = {
            "request_id": f"smoke_req_00{index}",
            "user_id": f"smoke_user_00{index}",
            "current_transactions": scen["current"],
            "historical_transactions": scen["history"],
        }
        res = assess_batch(payload)
        assessment = res["assessments"][0]

        item = {
            "scenario": scen["name"],
            "transaction_id": assessment["transaction_id"],
            "anomaly_score": assessment["anomaly_score"],
            "risk_band": assessment["risk_band"],
            "reason_codes": assessment["reason_codes"],
            "personal_baseline_status": assessment["personal_baseline_status"],
            "global_model_score": assessment["global_model_score"],
            "personal_model_score": assessment["personal_model_score"],
            "rule_score": assessment["rule_score"],
        }
        all_results.append(item)

        print(f"[{scen['name']}]")
        print(f"  transaction_id           : {item['transaction_id']}")
        print(f"  anomaly_score            : {item['anomaly_score']}")
        print(f"  risk_band                : {item['risk_band']}")
        print(f"  reason_codes             : {item['reason_codes']}")
        print(f"  personal_baseline_status : {item['personal_baseline_status']}")
        print(f"  global_model_score       : {item['global_model_score']}")
        print(f"  personal_model_score     : {item['personal_model_score']}")
        print(f"  rule_score               : {item['rule_score']}")
        print("-" * 80)

    return all_results


if __name__ == "__main__":
    run_smoke_test()
