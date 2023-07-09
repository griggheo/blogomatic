import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [posts, setPosts] = useState([]);
  const [newPostTitle, setNewPostTitle] = useState('');
  const [newPostContent, setNewPostContent] = useState('');
  const [editPostId, setEditPostId] = useState(null);

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    //const response = await fetch('https://' + window.location.hostname + ':443/posts');
    const response = await fetch('/posts');
    const data = await response.json();
    setPosts(data);
  };

  const createPost = async () => {
    //const response = await fetch('https://' + window.location.hostname + ':443/posts', {
    const response = await fetch('/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: newPostTitle, content: newPostContent }),
    });
    if (response.ok) {
      setNewPostTitle('');
      setNewPostContent('');
      fetchPosts();
    }
  };

  const deletePost = async (postId) => {
    const confirmed = window.confirm('Are you sure you want to delete this post?');
    if (confirmed) {
      //const response = await fetch('https://' + window.location.hostname + ':443/posts/${postId}', {
      const response = await fetch(`/posts/${postId}`, {
        method: 'DELETE',
      });
      if (response.ok) {
        fetchPosts();
      }
    }
  };

  const editPost = async (postId) => {
    setEditPostId(postId);
    const postToEdit = posts.find((post) => post.id === postId);
    if (postToEdit) {
      setNewPostTitle(postToEdit.title);
      setNewPostContent(postToEdit.content);
    }
  };

  const updatePost = async () => {
    //const response = await fetch('https://' + window.location.hostname + ':443/posts/${editPostId}', {
    const response = await fetch(`/posts/${editPostId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: newPostTitle, content: newPostContent }),
    });
    if (response.ok) {
      setEditPostId(null);
      setNewPostTitle('');
      setNewPostContent('');
      fetchPosts();
    }
  };

  return (
    <div className="App">
      <h1>Blogomatic</h1>
      <div>
        <h2>{editPostId ? 'Edit post' : 'Create new post'}</h2>
        <input
          type="text"
          value={newPostTitle}
          onChange={(e) => setNewPostTitle(e.target.value)}
          placeholder="Title"
        />
        <textarea
          value={newPostContent}
          onChange={(e) => setNewPostContent(e.target.value)}
          placeholder="Content"
        />
        {editPostId ? (
          <button onClick={updatePost}>Update</button>
        ) : (
          <button onClick={createPost}>Create</button>
        )}
      </div>
      <div>
        <h2>Posts</h2>
        {posts.map((post) => (
          <div key={post.id}>
            <h3>{post.title}</h3>
            <textarea className="post-content" value={post.content} readOnly />
            <p className="date">Posted on: {new Date(post.date).toLocaleString()}</p>
              <div className="button-group">
              <button onClick={() => editPost(post.id)}>Edit</button>
              <span className="button-space"></span>
              <button onClick={() => deletePost(post.id)}>Delete</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
