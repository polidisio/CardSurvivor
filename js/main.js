document.addEventListener('DOMContentLoaded', () => {
    const ackBtn = document.getElementById('ack-btn');
    const ackMessage = document.getElementById('ack-message');
    
    if (ackBtn) {
        ackBtn.addEventListener('click', () => {
            ackBtn.style.display = 'none';
            ackMessage.style.display = 'block';
            
            if (typeof window.va !== 'undefined') {
                window.va('event', {
                    name: 'phishing_training_completed',
                    props: {
                        language: document.documentElement.lang,
                        timestamp: new Date().toISOString()
                    }
                });
            }
            
            console.log('Training acknowledged', {
                language: document.documentElement.lang,
                timestamp: new Date().toISOString()
            });
        });
    }
    
    const observerOptions = {
        threshold: 0.1
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
            }
        });
    }, observerOptions);
    
    document.querySelectorAll('section').forEach(section => {
        section.style.opacity = '0';
        observer.observe(section);
    });
});
