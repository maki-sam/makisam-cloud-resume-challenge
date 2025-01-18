// script.js

document.addEventListener('DOMContentLoaded', () => {
    const apiURL = "https://x2zig37o7qcuvy4gujqyvm7e6q0eohqg.lambda-url.ap-southeast-1.on.aws/"; // Replace with your API URL
    const projectsContainer = document.getElementById('projects-container');
    const viewerCountElement = document.getElementById('viewer-count');

    // Fetch and display project data
    fetch(apiURL)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            projectsContainer.innerHTML = '';
            data.projects.forEach(project => {
                const projectDiv = document.createElement('div');
                projectDiv.classList.add('project');
                projectDiv.innerHTML = `
                    <h3>${project.name}</h3>
                    <p>${project.description}</p>
                    <a href="${project.link}" target="_blank">View Project</a>
                `;
                projectsContainer.appendChild(projectDiv);
            });
        })
        .catch(error => {
            projectsContainer.innerHTML = '<p>Failed to load projects. Please try again later.</p>';
            console.error('Error fetching projects:', error);
        });

    // Website Viewer Counter (simulating with localStorage for demo purposes)
    const viewerCountKey = 'portfolioViewerCount';
    let viewerCount = localStorage.getItem(viewerCountKey) || 0;
    viewerCount++;
    localStorage.setItem(viewerCountKey, viewerCount);

    viewerCountElement.textContent = `Website Views: ${viewerCount}`;
});
