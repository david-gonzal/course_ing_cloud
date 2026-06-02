
[ Cliente ] ──(Sube CSV)──> [ S3 Bucket ]
                                  │
                       (Notificación de Evento)
                                  ▼
                            [ SNS Topic ]
                                  │
                             (Pub / Sub)
                                  ▼
                            [ SQS Queue ]
                                  │
                               (Poll)
                                  ▼
                         [ Lambda Function ]


