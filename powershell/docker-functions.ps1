function Remove-OldDockerImages() {
    docker images -f "dangling=true" --quiet | % { docker image remove $_ }
}

function DockerComposeDown-ProjectWithPort([Parameter(Mandatory)][int]$Port) {
    $projects = docker ps --filter "publish=$Port" --format '{{.Label "com.docker.compose.project"}}' | ? { $_ } | select -Unique
    if ($projects) {
        $projects | % {
            if (Read-YesNo "Port $Port is published by compose project '$_'. Take the whole project down?") {
                docker compose -p $_ down
            }
        }
    }
}
