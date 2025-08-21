;; Certification and Compliance Management Contract
;; Manages organic certification, sustainable practices, and regulatory compliance

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-CERTIFICATION-NOT-FOUND (err u301))
(define-constant ERR-INVALID-INPUT (err u302))
(define-constant ERR-CERTIFICATION-ALREADY-EXISTS (err u303))
(define-constant ERR-CERTIFICATION-EXPIRED (err u304))
(define-constant ERR-AUDIT-NOT-FOUND (err u305))
(define-constant ERR-INVALID-STATUS (err u306))
(define-constant ERR-COMPLIANCE-VIOLATION (err u307))

;; Data Variables
(define-data-var next-audit-id uint u1)
(define-data-var next-violation-id uint u1)

;; Data Maps
(define-map certifications
  { cert-id: (string-ascii 64) }
  {
    holder: principal,
    cert-type: (string-ascii 64),
    cert-name: (string-ascii 128),
    issuing-body: (string-ascii 128),
    issue-date: uint,
    expiry-date: uint,
    status: (string-ascii 32),
    scope: (string-ascii 256),
    conditions: (list 20 (string-ascii 256)),
    renewal-required: bool,
    last-audit: (optional uint),
    next-audit: uint,
    created-at: uint,
    updated-at: uint
  }
)

(define-map sustainable-practices
  { holder: principal, practice-type: (string-ascii 64) }
  {
    practice-name: (string-ascii 128),
    description: (string-ascii 512),
    implementation-date: uint,
    verification-status: (string-ascii 32),
    impact-metrics: (list 10 (string-ascii 128)),
    documentation: (string-ascii 512),
    verifier: (optional principal),
    verified-date: (optional uint),
    compliance-score: uint,
    notes: (string-ascii 512)
  }
)

(define-map compliance-audits
  { audit-id: uint }
  {
    cert-id: (string-ascii 64),
    auditor: principal,
    audit-type: (string-ascii 64),
    audit-date: uint,
    status: (string-ascii 32),
    compliance-score: uint,
    findings: (list 50 (string-ascii 512)),
    recommendations: (list 30 (string-ascii 512)),
    corrective-actions: (list 30 (string-ascii 512)),
    follow-up-required: bool,
    follow-up-date: (optional uint),
    report-url: (string-ascii 256),
    created-at: uint
  }
)

(define-map regulatory-requirements
  { regulation-id: (string-ascii 64) }
  {
    regulation-name: (string-ascii 128),
    authority: (string-ascii 128),
    description: (string-ascii 512),
    compliance-criteria: (list 20 (string-ascii 256)),
    reporting-frequency: (string-ascii 32),
    penalty-for-violation: uint,
    effective-date: uint,
    last-updated: uint,
    active: bool
  }
)

(define-map compliance-records
  { holder: principal, regulation-id: (string-ascii 64) }
  {
    compliance-status: (string-ascii 32),
    last-check: uint,
    next-check: uint,
    compliance-score: uint,
    violations: (list 10 uint),
    corrective-measures: (list 20 (string-ascii 256)),
    documentation: (string-ascii 512),
    responsible-officer: (optional principal),
    notes: (string-ascii 512)
  }
)

(define-map compliance-violations
  { violation-id: uint }
  {
    holder: principal,
    regulation-id: (string-ascii 64),
    violation-type: (string-ascii 64),
    severity: (string-ascii 32),
    description: (string-ascii 512),
    detected-date: uint,
    reported-by: principal,
    status: (string-ascii 32),
    corrective-deadline: uint,
    penalty-amount: (optional uint),
    resolution-notes: (string-ascii 512),
    resolved-date: (optional uint)
  }
)

(define-map authorized-certifiers
  { certifier: principal }
  {
    name: (string-ascii 128),
    organization: (string-ascii 128),
    certification-types: (list 10 (string-ascii 64)),
    accreditation: (string-ascii 128),
    authorization-level: (string-ascii 32),
    authorized-by: principal,
    authorized-at: uint,
    active: bool
  }
)

(define-map authorized-auditors
  { auditor: principal }
  {
    name: (string-ascii 128),
    organization: (string-ascii 128),
    specializations: (list 10 (string-ascii 64)),
    credentials: (string-ascii 256),
    audit-count: uint,
    average-score: uint,
    authorized-by: principal,
    authorized-at: uint,
    active: bool
  }
)

;; Private Functions
(define-private (is-certification-holder (cert-id (string-ascii 64)) (caller principal))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data (is-eq (get holder cert-data) caller)
    false
  )
)

(define-private (is-authorized-certifier (caller principal))
  (match (map-get? authorized-certifiers { certifier: caller })
    certifier-data (get active certifier-data)
    false
  )
)

(define-private (is-authorized-auditor (caller principal))
  (match (map-get? authorized-auditors { auditor: caller })
    auditor-data (get active auditor-data)
    false
  )
)

(define-private (is-valid-cert-status (status (string-ascii 32)))
  (or
    (is-eq status "active")
    (is-eq status "expired")
    (is-eq status "suspended")
    (is-eq status "revoked")
    (is-eq status "pending-renewal")
  )
)

(define-private (is-certification-valid (cert-id (string-ascii 64)))
  (match (map-get? certifications { cert-id: cert-id })
    cert-data
      (let (
        (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
      )
        (and
          (is-eq (get status cert-data) "active")
          (> (get expiry-date cert-data) current-time)
        )
      )
    false
  )
)

;; Public Functions

;; Issue certification
(define-public (issue-certification
  (cert-id (string-ascii 64))
  (holder principal)
  (cert-type (string-ascii 64))
  (cert-name (string-ascii 128))
  (issuing-body (string-ascii 128))
  (validity-period uint)
  (scope (string-ascii 256))
  (conditions (list 20 (string-ascii 256)))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (expiry-date (+ current-time validity-period))
  )
    (asserts! (is-authorized-certifier tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len cert-id) u0) ERR-INVALID-INPUT)
    (asserts! (> validity-period u0) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? certifications { cert-id: cert-id })) ERR-CERTIFICATION-ALREADY-EXISTS)

    (map-set certifications
      { cert-id: cert-id }
      {
        holder: holder,
        cert-type: cert-type,
        cert-name: cert-name,
        issuing-body: issuing-body,
        issue-date: current-time,
        expiry-date: expiry-date,
        status: "active",
        scope: scope,
        conditions: conditions,
        renewal-required: false,
        last-audit: none,
        next-audit: (+ current-time u31536000), ;; 1 year from now
        created-at: current-time,
        updated-at: current-time
      }
    )
    (ok cert-id)
  )
)

;; Renew certification
(define-public (renew-certification
  (cert-id (string-ascii 64))
  (validity-period uint)
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-CERTIFICATION-NOT-FOUND))
    (new-expiry (+ current-time validity-period))
  )
    (asserts! (is-authorized-certifier tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> validity-period u0) ERR-INVALID-INPUT)

    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data {
        expiry-date: new-expiry,
        status: "active",
        renewal-required: false,
        updated-at: current-time
      })
    )
    (ok true)
  )
)

;; Record sustainable practice
(define-public (record-sustainable-practice
  (practice-type (string-ascii 64))
  (practice-name (string-ascii 128))
  (description (string-ascii 512))
  (impact-metrics (list 10 (string-ascii 128)))
  (documentation (string-ascii 512))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (> (len practice-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len practice-name) u0) ERR-INVALID-INPUT)

    (map-set sustainable-practices
      { holder: tx-sender, practice-type: practice-type }
      {
        practice-name: practice-name,
        description: description,
        implementation-date: current-time,
        verification-status: "pending",
        impact-metrics: impact-metrics,
        documentation: documentation,
        verifier: none,
        verified-date: none,
        compliance-score: u0,
        notes: ""
      }
    )
    (ok true)
  )
)

;; Verify sustainable practice
(define-public (verify-sustainable-practice
  (holder principal)
  (practice-type (string-ascii 64))
  (compliance-score uint)
  (notes (string-ascii 512))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (practice-data (unwrap! (map-get? sustainable-practices { holder: holder, practice-type: practice-type }) ERR-CERTIFICATION-NOT-FOUND))
  )
    (asserts! (is-authorized-auditor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= compliance-score u100) ERR-INVALID-INPUT)

    (map-set sustainable-practices
      { holder: holder, practice-type: practice-type }
      (merge practice-data {
        verification-status: (if (>= compliance-score u70) "verified" "non-compliant"),
        verifier: (some tx-sender),
        verified-date: (some current-time),
        compliance-score: compliance-score,
        notes: notes
      })
    )
    (ok true)
  )
)

;; Conduct compliance audit
(define-public (conduct-compliance-audit
  (cert-id (string-ascii 64))
  (audit-type (string-ascii 64))
  (compliance-score uint)
  (findings (list 50 (string-ascii 512)))
  (recommendations (list 30 (string-ascii 512)))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (audit-id (var-get next-audit-id))
    (cert-data (unwrap! (map-get? certifications { cert-id: cert-id }) ERR-CERTIFICATION-NOT-FOUND))
  )
    (asserts! (is-authorized-auditor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (<= compliance-score u100) ERR-INVALID-INPUT)
    (asserts! (is-certification-valid cert-id) ERR-CERTIFICATION-EXPIRED)

    (map-set compliance-audits
      { audit-id: audit-id }
      {
        cert-id: cert-id,
        auditor: tx-sender,
        audit-type: audit-type,
        audit-date: current-time,
        status: "completed",
        compliance-score: compliance-score,
        findings: findings,
        recommendations: recommendations,
        corrective-actions: (list),
        follow-up-required: (< compliance-score u80),
        follow-up-date: (if (< compliance-score u80) (some (+ current-time u2592000)) none), ;; 30 days
        report-url: "",
        created-at: current-time
      }
    )

    ;; Update certification with audit info
    (map-set certifications
      { cert-id: cert-id }
      (merge cert-data {
        last-audit: (some current-time),
        next-audit: (+ current-time u31536000), ;; 1 year from now
        renewal-required: (< compliance-score u70),
        updated-at: current-time
      })
    )

    (var-set next-audit-id (+ audit-id u1))
    (ok audit-id)
  )
)

;; Report compliance violation
(define-public (report-compliance-violation
  (holder principal)
  (regulation-id (string-ascii 64))
  (violation-type (string-ascii 64))
  (severity (string-ascii 32))
  (description (string-ascii 512))
  (corrective-deadline uint)
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (violation-id (var-get next-violation-id))
  )
    (asserts! (is-authorized-auditor tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len violation-type) u0) ERR-INVALID-INPUT)
    (asserts! (> corrective-deadline current-time) ERR-INVALID-INPUT)

    (map-set compliance-violations
      { violation-id: violation-id }
      {
        holder: holder,
        regulation-id: regulation-id,
        violation-type: violation-type,
        severity: severity,
        description: description,
        detected-date: current-time,
        reported-by: tx-sender,
        status: "open",
        corrective-deadline: corrective-deadline,
        penalty-amount: none,
        resolution-notes: "",
        resolved-date: none
      }
    )

    (var-set next-violation-id (+ violation-id u1))
    (ok violation-id)
  )
)

;; Resolve compliance violation
(define-public (resolve-compliance-violation
  (violation-id uint)
  (resolution-notes (string-ascii 512))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
    (violation-data (unwrap! (map-get? compliance-violations { violation-id: violation-id }) ERR-AUDIT-NOT-FOUND))
  )
    (asserts! (is-eq (get holder violation-data) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status violation-data) "open") ERR-INVALID-STATUS)

    (map-set compliance-violations
      { violation-id: violation-id }
      (merge violation-data {
        status: "resolved",
        resolution-notes: resolution-notes,
        resolved-date: (some current-time)
      })
    )
    (ok true)
  )
)

;; Add regulatory requirement
(define-public (add-regulatory-requirement
  (regulation-id (string-ascii 64))
  (regulation-name (string-ascii 128))
  (authority (string-ascii 128))
  (description (string-ascii 512))
  (compliance-criteria (list 20 (string-ascii 256)))
  (reporting-frequency (string-ascii 32))
  (penalty-for-violation uint)
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len regulation-id) u0) ERR-INVALID-INPUT)

    (map-set regulatory-requirements
      { regulation-id: regulation-id }
      {
        regulation-name: regulation-name,
        authority: authority,
        description: description,
        compliance-criteria: compliance-criteria,
        reporting-frequency: reporting-frequency,
        penalty-for-violation: penalty-for-violation,
        effective-date: current-time,
        last-updated: current-time,
        active: true
      }
    )
    (ok true)
  )
)

;; Authorize certifier
(define-public (authorize-certifier
  (certifier principal)
  (name (string-ascii 128))
  (organization (string-ascii 128))
  (certification-types (list 10 (string-ascii 64)))
  (accreditation (string-ascii 128))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)

    (map-set authorized-certifiers
      { certifier: certifier }
      {
        name: name,
        organization: organization,
        certification-types: certification-types,
        accreditation: accreditation,
        authorization-level: "standard",
        authorized-by: tx-sender,
        authorized-at: current-time,
        active: true
      }
    )
    (ok true)
  )
)

;; Authorize auditor
(define-public (authorize-auditor
  (auditor principal)
  (name (string-ascii 128))
  (organization (string-ascii 128))
  (specializations (list 10 (string-ascii 64)))
  (credentials (string-ascii 256))
)
  (let (
    (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)

    (map-set authorized-auditors
      { auditor: auditor }
      {
        name: name,
        organization: organization,
        specializations: specializations,
        credentials: credentials,
        audit-count: u0,
        average-score: u0,
        authorized-by: tx-sender,
        authorized-at: current-time,
        active: true
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get certification details
(define-read-only (get-certification (cert-id (string-ascii 64)))
  (map-get? certifications { cert-id: cert-id })
)

;; Get sustainable practice
(define-read-only (get-sustainable-practice
  (holder principal)
  (practice-type (string-ascii 64))
)
  (map-get? sustainable-practices { holder: holder, practice-type: practice-type })
)

;; Get compliance audit
(define-read-only (get-compliance-audit (audit-id uint))
  (map-get? compliance-audits { audit-id: audit-id })
)

;; Get compliance violation
(define-read-only (get-compliance-violation (violation-id uint))
  (map-get? compliance-violations { violation-id: violation-id })
)

;; Get regulatory requirement
(define-read-only (get-regulatory-requirement (regulation-id (string-ascii 64)))
  (map-get? regulatory-requirements { regulation-id: regulation-id })
)

;; Check certification validity
(define-read-only (is-cert-valid (cert-id (string-ascii 64)))
  (is-certification-valid cert-id)
)

;; Get certifier authorization
(define-read-only (get-certifier-auth (certifier principal))
  (map-get? authorized-certifiers { certifier: certifier })
)

;; Get auditor authorization
(define-read-only (get-auditor-auth (auditor principal))
  (map-get? authorized-auditors { auditor: auditor })
)

;; Check compliance status
(define-read-only (get-compliance-status
  (holder principal)
  (regulation-id (string-ascii 64))
)
  (map-get? compliance-records { holder: holder, regulation-id: regulation-id })
)
