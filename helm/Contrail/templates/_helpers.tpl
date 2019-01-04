{{- define "nodes" -}}
{{- $nameSpace := index . 0 }}
{{- $nodeType := index . 1 }}
{{- $svcType := index . 2 }}
{{- $nodeCount := index . 3 | int }}
  {{- range $index0 := until $nodeCount -}}
    {{- $index1 := $index0 | add1 -}}
{{ $nodeType }}-{{ $index0 }}.{{ $svcType }}.{{ $nameSpace }}.svc.cluster.local{{ if ne $index1 $nodeCount }},{{ end }}
  {{- end -}}
{{- end -}}

{{- define "zknodes" -}}
{{- $nameSpace := index . 0 }}
{{- $nodeType := index . 1 }}
{{- $svcType := index . 2 }}
{{- $nodeCount := index . 3 | int }}
  {{- range $index0 := until $nodeCount -}}
    {{- $index1 := $index0 | add1 -}}
{{ $nodeType }}-{{ $index0 }}.{{ $svcType }}.{{ $nameSpace }}.svc.cluster.local:2181{{ if ne $index1 $nodeCount }},{{ end }}
  {{- end -}}
{{- end -}}
