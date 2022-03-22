[to_entries[]
    | .value + { "language": .key, "files": .value.reports | length, "lines": (.value.blanks+.value.code+.value.comments) }
    | del( .["reports", "children","inaccurate"] )
]
| sort_by(.lines)
| reverse
| map([($date | @json), (.language | @json), .files, .lines, .code, .comments, .blanks] | join(","))
| join("\n")
