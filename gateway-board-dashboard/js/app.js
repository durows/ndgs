function fmtNumber(value) {
  return new Intl.NumberFormat('en-US').format(value ?? 0);
}

function fmtPct(value) {
  return `${Number(value ?? 0).toFixed(1)}%`;
}

function setText(id, value) {
  const el = document.getElementById(id);
  if (el) el.textContent = value;
}

function buildMissionBars(mission) {
  const rows = [
    { label: 'Students reached statewide', value: mission.student_penetration_pct },
    { label: 'Residents engaged statewide', value: mission.population_pct },
    { label: 'Schools served statewide', value: mission.schools_pct }
  ];

  const wrap = document.getElementById('missionBars');
  wrap.innerHTML = rows.map(row => `
    <div class="bar-item" title="${row.label}: ${fmtPct(row.value)}">
      <div class="bar-top">
        <span>${row.label}</span>
        <strong>${fmtPct(row.value)}</strong>
      </div>
      <div class="bar-track">
        <div class="bar-fill" style="width:${Math.max(0, Math.min(100, row.value))}%"></div>
      </div>
    </div>
  `).join('');
}

function buildRevenueMix(financial) {
  const stack = document.getElementById('revenueStack');
  const legend = document.getElementById('revenueLegend');
  const palette = ['#0b6f8f', '#2d91b3', '#7bc0d6', '#b8851a', '#4e8b61'];

  stack.innerHTML = financial.revenue_sources.map((item, idx) => `
    <div
      class="stack-segment"
      style="width:${item.pct}%; background:${palette[idx % palette.length]}"
      title="${item.name}: ${item.pct}%"
    ></div>
  `).join('');

  legend.innerHTML = financial.revenue_sources.map((item, idx) => `
    <div class="legend-item" title="${item.name} represents ${item.pct}% of revenue.">
      <div class="legend-left">
        <span class="swatch" style="background:${palette[idx % palette.length]}"></span>
        <span>${item.name}</span>
      </div>
      <strong>${item.pct}%</strong>
    </div>
  `).join('');
}

function buildNarrative(data) {
  const { mission, financial, sustainability, indexes } = data;
  const summary = `Gateway reaches 1 in ${Math.round(100 / mission.student_penetration_pct)} students, 1 in ${Math.round(100 / mission.population_pct)} residents, and ${fmtPct(mission.schools_pct)} of schools, while maintaining ${financial.earned_revenue_pct}% earned revenue and a current health score of ${indexes.overall_health_score}/100.`;
  setText('storyStrip', summary);

  setText(
    'missionCallout',
    `Gateway reaches 1 in ${Math.round(100 / mission.student_penetration_pct)} students, 1 in ${Math.round(100 / mission.population_pct)} residents, and over one-third of schools.`
  );

  setText(
    'sustainabilityCallout',
    `Gateway is positioned as more than a local asset. The next question is whether statewide participation, outreach, and partnerships continue to deepen.`
  );
}

async function loadDashboard() {
  const response = await fetch('data/board_metrics.json');
  const data = await response.json();

  setText('overallHealthScore', data.indexes.overall_health_score);
  setText('missionIndex', data.indexes.mission_impact_index);
  setText('financialIndex', data.indexes.financial_strength_index);
  setText('sustainabilityIndex', data.indexes.sustainability_index);

  setText('studentsImpacted', fmtNumber(data.mission.students_impacted));
  setText('populationEngaged', fmtNumber(data.mission.population_engaged));
  setText('schoolsReached', fmtNumber(data.mission.schools_reached));
  setText('studentsPenetration', `${fmtPct(data.mission.student_penetration_pct)} of students statewide`);
  setText('populationPct', `${fmtPct(data.mission.population_pct)} of total population`);
  setText('schoolsPct', `${fmtPct(data.mission.schools_pct)} of schools served`);

  setText('earnedRevenuePct', fmtPct(data.financial.earned_revenue_pct));
  setText('programSpendingPct', fmtPct(data.financial.program_spending_pct));
  setText('diversificationScore', `${data.financial.diversification_score}/100`);
  setText('programSpendValue', fmtPct(data.financial.program_spending_pct));
  setText('adminSpendValue', fmtPct(data.financial.admin_spending_pct));

  setText('nonLocalPct', fmtPct(data.sustainability.non_local_participation_pct));
  setText('outreachPct', fmtPct(data.sustainability.outreach_engagement_pct));
  setText('partnershipsCount', fmtNumber(data.sustainability.strategic_partnerships));

  setText('geoReachText', `${fmtPct(data.sustainability.non_local_participation_pct)} non-local`);
  document.getElementById('geoReachFill').style.width = `${data.sustainability.non_local_participation_pct}%`;

  setText('outreachText', `${fmtPct(data.sustainability.outreach_engagement_pct)} outreach`);
  document.getElementById('outreachFill').style.width = `${data.sustainability.outreach_engagement_pct}%`;

  buildMissionBars(data.mission);
  buildRevenueMix(data.financial);
  buildNarrative(data);
}

loadDashboard().catch(err => {
  console.error(err);
  setText('storyStrip', 'Unable to load dashboard data. Confirm that board_metrics.json is in the data folder.');
});
