# plot_config.py
COLORS = {'A': "#D55E00", 'B': "#0072B2"}

EVENT_LINES = [
    {'date': '2023-10-18', 'color': 'black', 'linestyle': '--',
     'label_parts': [{"text": "sowing", "color": "black"}]},

    {'date': '2024-03-05', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [
         {"text": "BAU: 30 kg N ha$^{-1}$", "color": COLORS["A"]},
         {"text": "VRA: 32 kg N ha$^{-1}$", "color": COLORS["B"]},
     ]},

    {'date': '2024-04-09', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [
         {"text": "BAU: 56 kg N ha$^{-1}$", "color": COLORS["A"]},
         {"text": "VRA: 80 kg N ha$^{-1}$", "color": COLORS["B"]},
     ]},

    {'date': '2024-05-06', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [{"text": "BAU: 66 kg N ha$^{-1}$", "color": COLORS["A"]}]},

    {'date': '2024-05-15', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [{"text": "VRA: 33 kg N ha$^{-1}$", "color": COLORS["B"]}]},

    {'date': '2024-07-25', 'color': 'black', 'linestyle': '--',
     'label_parts': [{"text": "harvest", "color": "black"}]},

    {'date': '2024-07-28', 'color': 'black', 'linestyle': '--',
     'label_parts': [{"text": "harrowing", "color": "black"}]},

    {'date': '2024-08-05', 'color': 'black', 'linestyle': '--',
     'label_parts': [{"text": "cultivation", "color": "black"}]},

    {'date': '2024-08-22', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [{"text": "188 kg N ha$^{-1}$\n[slurry digestate]", "color": "black"}]},

    {'date': '2025-03-06', 'color': 'black', 'linestyle': 'dotted',
     'label_parts': [{"text": "80 kg N ha$^{-1}$\n[slurry]", "color": "black"}]},
]

PERIODS = {
    "complete_period": ("2023-10-18", "2024-08-21"),
    "wheat_growing_season": ("2023-11-07", "2024-07-23"),
    "wheat_treatment_period": ("2024-03-05", "2024-07-23"),
    "post_wheat_harvest_period": ("2024-08-07", "2024-08-21")
}

LABELS = {
    "A": "Business-as-usual (BAU)",
    "B": "Variable rate application (VRA)"
}


def add_event_lines(
    ax,
    event_lines=EVENT_LINES,
    height=1.05,
    x_spacing_days=3,
    start_ts=None,
    end_ts=None,
    mgmt=True
):
    """
    Draw vertical event lines and optional colored label parts.
    start_ts/end_ts can be strings or pandas Timestamps.
    If start_ts/end_ts are None, all events are drawn.
    """
    import pandas as pd

    if start_ts is not None:
        start_ts = pd.to_datetime(start_ts)
    if end_ts is not None:
        end_ts = pd.to_datetime(end_ts)

    for ev in event_lines:
        evd = pd.to_datetime(ev["date"])

        # Filter if bounds provided
        if start_ts is not None and evd < start_ts:
            continue
        if end_ts is not None and evd > end_ts:
            continue

        ax.axvline(
            evd,
            color=ev.get("color", "black"),
            linestyle=ev.get("linestyle", "dotted"),
            linewidth=1.2,
            zorder=0
        )

        if mgmt:
            parts = ev.get("label_parts", [])
            n = len(parts)
            for i, part in enumerate(parts):
                x_off = (i - (n - 1) / 2) * x_spacing_days
                ax.text(
                    evd + pd.Timedelta(days=x_off),
                    height,
                    part["text"],
                    transform=ax.get_xaxis_transform(),
                    rotation=90, va="bottom", ha="center",
                    color=part.get("color", "black")
                )
        