// ──────────────────────────────────────────────────────────────
// MedCore API — Minimal starting point
// ──────────────────────────────────────────────────────────────
// Phase 1: /health endpoint only (prove deploy works)
// Phase 2: Add SQL, Key Vault, App Insights integrations
// Phase 3: Add patient CRUD with multi-tenant clinic_id
// ──────────────────────────────────────────────────────────────

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// ─── Health check (App Service pings this every 5 min) ───
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    service = "MedCore.Api",
    version = "1.0.0",
    timestamp = DateTime.UtcNow
}));

// ─── Root — friendly landing ───
app.MapGet("/", () => Results.Ok(new
{
    message = "MedCore Patient Record System 2",
    docs = "/health",
    environment = app.Environment.EnvironmentName
}));

app.Run();

