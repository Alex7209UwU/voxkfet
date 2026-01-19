# Simple HTTP Server using PowerShell
$port = 8080
$path = Get-Location

Add-Type @"
    using System;
    using System.IO;
    using System.Net;
    using System.Text;

    public class SimpleHttpServer
    {
        private HttpListener listener;
        private string basePath;
        
        public SimpleHttpServer(string path, int port)
        {
            basePath = path;
            listener = new HttpListener();
            listener.Prefixes.Add($"http://localhost:{port}/");
        }
        
        public void Start()
        {
            listener.Start();
            Console.WriteLine($"Server started at http://localhost:8080");
            
            while (true)
            {
                HttpListenerContext context = listener.GetContext();
                HttpListenerRequest request = context.Request;
                HttpListenerResponse response = context.Response;
                
                string filePath = Path.Combine(basePath, request.Url.AbsolutePath.TrimStart('/'));
                
                if (Directory.Exists(filePath))
                    filePath = Path.Combine(filePath, "index.html");
                
                if (File.Exists(filePath))
                {
                    byte[] buffer = File.ReadAllBytes(filePath);
                    response.ContentLength64 = buffer.Length;
                    response.OutputStream.Write(buffer, 0, buffer.Length);
                }
                else
                {
                    response.StatusCode = 404;
                }
                
                response.OutputStream.Close();
            }
        }
    }
"@

$server = New-Object SimpleHttpServer($path, $port)
$server.Start()
