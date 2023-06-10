import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [posts, setPosts] = useState([]);
  const [newPostTitle, setNewPostTitle] = useState("");
  const [newPostContent, setNewPostContent] = useState("");

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    const response = await fetch("http://localhost:8080/posts");
    const data = await response.json();
    setPosts(data);
  }

  const createPost = async () => {
    const response = await fetch("http://localhost:8080/posts", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: newPostTitle, content: newPostContent })
    });
    if (response.ok) {
      setNewPostTitle("");
      setNewPostContent("");
      fetchPosts();
    }
  }

  return (
    <div className="App">
      <h1>Blogomatic</h1>
      <div>
        <h2>Create new post</h2>
        <input 
          type="text"
          value={newPostTitle}
          onChange={e => setNewPostTitle(e.target.value)}
          placeholder="Title"
        />
        <textarea 
          value={newPostContent}
          onChange={e => setNewPostContent(e.target.value)}
          placeholder="Content"
        />
        <button onClick={createPost}>Create</button>
      </div>
      <div>
        <h2>Posts</h2>
        {posts.map(post => (
          <div key={post.id}>
            <h3>{post.title}</h3>
            <textarea
              className="post-content"
              value={post.content}
              readOnly
            />
            <p className="date">Posted on: {new Date(post.date).toLocaleString()}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
