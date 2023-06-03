// Chart is loaded in admin template from Skypack
if (typeof Chart !== "undefined") {
  Chart.register(ChartStreaming)

  Chart.defaults.set('plugins.streaming', {
    duration: 20000,
  })
}

export const InitChart = {
  mounted() {
    const myChart = new Chart(this.el, {
      type: 'line',
      data: {
        datasets: [
          {
            label: this.el.dataset.label,
            backgroundColor: 'transparent',
            borderColor: '#a991f7',
            data: [65, 59, 84, 84, 51, 55, 40],
          },
        ],
      },
      options: {
        plugins: {
          legend: {
            display: false,
          },
          streaming: {
            duration: 60 * 1000,
            delay: 500
          },
        },
        maintainAspectRatio: false,
        scales: {
          x: {
            grid: {
              display: false,
              drawBorder: false,
            },
            ticks: {
              display: false,
            },
            type: 'realtime',
          },
          y: {
            min: 30,
            max: 89,
            display: false,
            grid: {
              display: false,
            },
            ticks: {
              display: false,
            },
          },
        },
        elements: {
          line: {
            borderWidth: 3,
            tension: 0.4,
          },
          point: {
            radius: 2,
            hoverRadius: 2,
          },
        },
      },
    })

    this.handleEvent('new-point', ({ label, value }) => {
      myChart.data.datasets[0].data.push({
        x: Date.now(),
        y: value
      })
    })
  },
}
