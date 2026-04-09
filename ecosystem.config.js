module.exports = {
  apps: [
    {
      name: 'trashtrove',
      script: 'node_modules/.bin/next',
      args: 'start -p 3002',
      cwd: '/home/joe/projects/trash-trove',
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3002,
      },
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
    },
  ],
};
