# Mermaid Examples

## Types

### Flowchart

```mermaid
flowchart LR
  A -- something --> B
```

### Sequence Diagram

```mermaid
%%{init: { 'sequence': { 'mirrorActors': false } }}%%
sequenceDiagram
  participant A
  participant B
  A ->> B: something
  B ->> A: something
```

### Class Diagram

```mermaid
classDiagram
  class A {
    +prop
    +method()
  }
  A *-- B
  class B {
    +x()
  }
```

### State Diagram

```mermaid
stateDiagram-v2
  direction LR
  [*] --> A
  A --> B: something
  A --> [*]: something
  B --> [*]: something
```

### Entity Relationship Diagram

```mermaid
erDiagram
  A {
    string x PK "note"
  }
  B {
    int y FK "note"
  }
  A }o--|| B: something
```

### Journey

```mermaid
journey
  title Something
  section A
    x: 5: user1
    y: 1: user1,user2
    z: 3: user1
  section B
    t: 2: user2
    u: 1: user2,user1
    v: 4: user2
```

### Gantt

```mermaid
gantt
  dateFormat MM-DD
  title Something
  excludes weekends

  section A
    x: done, id_x, today, 7d
    y: active, id_y, after id_x, 2d

  section B
    t: crit, active, id_t, today, 3d
    v: milestone, after id_t
    u: id_u, after id_y, 1d
```

### Pie Chart

```mermaid
pie showdata
  title Something
  "A" : 150
  "B" : 50
```

### Requirement Diagram

```mermaid
requirementDiagram
  requirement A {
    id: A
    text: something
    risk: high
    verifymethod: test
  }

  element B {
    type: something
  }

  B - satisfies -> A
```

### Gitgraph (Git) Diagram

```mermaid
%%{ init: { 'gitGraph': { 'mainBranchName': 'master' } } }%%
gitGraph
  commit
  commit
  branch tmp
  commit
  checkout master
  merge tmp
  commit
```

## Details

### Sequence Diagram

https://mermaid-js.github.io/mermaid/#/sequenceDiagram

https://mermaid-js.github.io/mermaid/#/sequenceDiagram?id=configuration

```mermaid
%%{ init: { 'sequence': { 'showSequenceNumbers': false, 'mirrorActors': true } } }%%
sequenceDiagram
    # Note left of A: Ordering, Actor, Alias, Actor Menus
    actor F as First
    participant A
    link A: Bing @ https://bing.com
    link A: Dashboard @ https://bing.com
    links B: { "Bing": "https://bing.com", "Dashboard": "https://bing.com" }
    Note left of A: Arrows
    A -> B: solid line without arrow
    A --> B: dotted line without arrow
    A ->> B: solid line with arrowhead
    A -->> B: dotted line with arrowhead
    A -x B: solid line with a cross at the end
    A --x B: dotted line with a cross at the end
    A -) B: solid line with an open arrow at the end (async)
    A --) B: dotted line with a open arrow at the end (async)
    Note left of A: Activation
    A ->> B: activate B
    activate B
    A ->> B: deactivate B
    deactivate B
    A ->> +B: A ->> +B
    A ->> +B: A ->> +B
    B ->> -A: B ->> -A
    B ->> -A: B ->> -A
    Note left of A: Notes
    Note right of A: Note right of A
    Note left of B: Note left of B
    Note over A, B: Note over A, B
    Note left of A: Loop
    loop some loop
        A ->> B: text
    end
    Note left of A: Alt
    alt some alt 1
        A ->> B: text
    else some alt 2
        B ->> A: text
    end
    opt some opt
        A ->> B: text
    end
    Note left of A: Parallel
    par action 1
        A ->> B: text
    and action 2
        B ->> A: text
    end
    Note left of A: Critical
    critical critical 1
       A ->> B: text
    option option 1
       B ->> A: text
    end
    Note left of A: Break
    break some break
       A ->> B: text
    end
    Note left of A: Background
    rect rgb(0, 128, 0, .5)
        A ->> B: text
    end
    Note left of A: Sequence Numbers
    autonumber
    A ->> B: autonumber
    B ->> A: text
    autonumber 1
    A ->> B: autonumber 1
    B ->> A: text
    autonumber off
    A ->> B: autonumber off
```

### Gitgraph (Git) Diagram

https://mermaid-js.github.io/mermaid/#/gitgraph

```mermaid
%%{ init: { 'themeVariables': { 'commitLabelFontSize': '14px', 'tagLabelFontSize': '12px' }, 'gitGraph': { 'mainBranchName': 'master', 'mainBranchOrder': 0, 'showBranches': true, 'showCommitLabel': true, 'rotateCommitLabel': true } } }%%
gitGraph
  commit id: "normal" type: normal
  commit id: "reverse" type: reverse
  commit id: "highlight" type: highlight
  commit tag: "tag"
  branch bugfix order: 1
  commit
  checkout master
  commit
  merge bugfix tag:"tag2"
  branch bugfix2 order: 2
  commit id: "tmp"
  checkout master
  cherry-pick id: "tmp"
  commit
```
