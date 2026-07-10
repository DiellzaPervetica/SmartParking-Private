from __future__ import annotations

from datetime import datetime, timedelta, timezone

from app.utils.time_utils import utc_now


class HealthService:
    @staticmethod
    def summarize_sensor_health(spot_rows: list[dict]) -> dict:
        now = utc_now()
        low_battery = 0
        weak_signal = 0
        stale = 0

        for row in spot_rows:
            if (row.get("battery_level") or 0) < 20:
                low_battery += 1
            if (row.get("signal_strength") or -999) < -85:
                weak_signal += 1
            last_update = row.get("last_update")
            if isinstance(last_update, datetime) and last_update.tzinfo is None:
                last_update = last_update.replace(tzinfo=timezone.utc)
            if last_update and now - last_update > timedelta(minutes=5):
                stale += 1

        total = len(spot_rows)
        return {
            "total_spots": total,
            "low_battery_spots": low_battery,
            "weak_signal_spots": weak_signal,
            "stale_spots": stale,
        }
