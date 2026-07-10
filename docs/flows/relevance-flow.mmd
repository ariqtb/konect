---
title: ML Relevance Scoring — Pipeline Flow
---

flowchart TB
    %% ==================== STYLE DEFINITIONS ====================
    classDef frontend fill:#E3F2FD,stroke:#1565C0,stroke-width:2,color:#0D47A1
    classDef backend fill:#FFF3E0,stroke:#E65100,stroke-width:2,color:#BF360C
    classDef ml fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2,color:#4A148C
    classDef db fill:#E8F5E9,stroke:#2E7D32,stroke-width:2,color:#1B5E20
    classDef graph fill:#FFFDE7,stroke:#F57F17,stroke-width:2,color:#E65100
    classDef phase fill:#E0E0E0,stroke:#616161,stroke-width:1,color:#333

    %% ===================== NODES ================================

    subgraph Frontend["🌐 Frontend (React)"]
        direction TB
        UI[("User Posts<br/>Topic / Idea / Comment")]
        FG["react-force-graph-2d<br/>Node Graph Canvas"]
        FG_Style["Node Size = F(score)<br/>Edge Thickness = F(score)<br/>Color = Cluster<br/>Link Distance = 1 - score"]
    end

    subgraph Backend["⚡ API (Python FastAPI)"]
        direction TB
        API_REST["POST /api/relevance/score<br/>POST /api/relevance/batch<br/>POST /api/relevance/graph"]
        BIZ_LOGIC["Graph Builder<br/>→ Map scores → nodes/edges<br/>→ Assign colors by cluster<br/>→ Calculate link distances"]
    end

    subgraph ML["🧠 ML Service"]
        direction TB
        BI_ENCODER["Bi-Encoder<br/>all-MiniLM-L6-v2<br/>384d embeddings<br/>~10k teks/detik"]
        CROSS_ENCODER["Cross-Encoder<br/>ms-marco-MiniLM-L6-v2<br/>Pair classification<br/>1.800 pair/detik"]
        SCORE_CALC["Relevance Score<br/>(topic, teks) → 0.0–1.0"]
        CLUSTER["Semantic Clustering<br/>Cosine similarity → group"]
        SCORE_CACHE["Score Cache<br/>TTL: 5 menit"]
    end

    subgraph DB["🗄️ Supabase / PostgreSQL"]
        direction TB
        TOPICS["topics<br/>+ embedding vector(384)"]
        IDEAS["ideas<br/>+ embedding vector(384)"]
        COMMENTS["comments<br/>+ embedding vector(384)"]
        PG_VECTOR["pgvector<br/>Nearest Neighbor Query<br/>SELECT * FROM get_relevant_nodes()"]
    end

    subgraph DEPLOY["🚀 Deployment"]
        DIR_TRAIN["Fine-tune Pipeline<br/>Python / BinaryCrossEntropyLoss<br/>500+ labeled pairs → model-v2"]
    end

    %% ===================== FLOW =================================

    %% User Flow
    UI --> |"1. User posts topic/idea/comment"| API_REST

    %% Embedding Pipeline
    API_REST --> |"2. Generate embedding"| BI_ENCODER
    BI_ENCODER --> |"3. Simpan embedding"| TOPICS
    BI_ENCODER --> |"3. Simpan embedding"| IDEAS
    BI_ENCODER --> |"3. Simpan embedding"| COMMENTS

    %% Relevance Pipeline
    API_REST --> |"4. Score relevance (topic,teks)"| CROSS_ENCODER
    CROSS_ENCODER --> |"5. Raw score 0.0-1.0"| SCORE_CACHE
    SCORE_CACHE --> |"6. Convert ke graph params"| BIZ_LOGIC

    %% Clustering
    BI_ENCODER --> |"7. Query similar nodes"| PG_VECTOR
    PG_VECTOR --> |"8. Similarity scores"| CLUSTER
    CLUSTER --> |"9. Group + color assignment"| BIZ_LOGIC

    %% Return to Frontend
    BIZ_LOGIC --> |"10. { nodes, edges, positions }"| FG

    %% Graph Rendering
    FG --> |"Force-directed layout<br/>d3-force engine"| FG_Style
    FG_Style --> |"Interactive canvas<br/>Zoom / Pan / Drag / Click"| FG

    %% Fine-tune Flow
    DEPLOY -.-> |"Finetune model on labeled data"| CROSS_ENCODER
    DIR_TRAIN -.-> |"export model-v2 → replace"| CROSS_ENCODER

    %% ===================== ANNOTATIONS ==========================

    FG_Style -.- NOTE1["🎯 Semakin relevan = semakin dekat ke pusat"]
    BI_ENCODER -.- NOTE2["🚀 Bi-Encoder: Embedding untuk search & cluster"]
    CROSS_ENCODER -.- NOTE3["🎯 Cross-Encoder: Akurasi tinggi untuk pairwise score"]
    SCORE_CACHE -.- NOTE4["💡 Cache TTL: 5 menit / invalidate on new post"]