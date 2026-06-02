# GLOBAL CONFIG
FS = 48000
Q_FORMAT = 14

# FILTER CONFIGURATION
filters = [

    # LPF
    {
        "sw": 0,
        "type": "low",
        "fc": 500,
        "order": 4
    },

    {
        "sw": 1,
        "type": "low",
        "fc": 800,
        "order": 4
    },

    {
        "sw": 2,
        "type": "low",
        "fc": 1000,
        "order": 4
    },

    # HPF
    {
        "sw": 3,
        "type": "high",
        "fc": 500,
        "order": 4
    },

    {
        "sw": 4,
        "type": "high",
        "fc": 800,
        "order": 4
    },

    {
        "sw": 5,
        "type": "high",
        "fc": 1000,
        "order": 4
    },

    # BPF
    {
        "sw": 6,
        "type": "bandpass",
        "fc": [500,1000],
        "order": 2
    },

    # BSF
    {
        "sw": 7,
        "type": "bandstop",
        "fc": [500,1000],
        "order": 2
    }
]