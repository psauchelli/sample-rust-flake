use axum::{
    Router, 
    routing::get,
    response::IntoResponse,
    Json,
};


async fn root() -> impl IntoResponse {
    const MESSAGE: &str = "Simple API";

    let json_response = serde_json::json!({
        "status": "success",
        "message": MESSAGE
    });

    Json(json_response)
}

async fn eavs() -> impl IntoResponse {
    const MESSAGE: &str = "eavs endpoint";

    let json_response = serde_json::json!({
        "status": "hell yeah",
        "message": MESSAGE
    });

    Json(json_response)
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/eavs", get(eavs))
        .route("/", get(root));
    
    println!("server started successfully");

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
