#!/usr/bin/env node
/**
 * Score company_skills by relevance to agent name, role, and description.
 * Uses fuzzy matching on skill name, description, and content (markdown).
 * Outputs SQL to update existing skills with relevance scores.
 */

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('Error: Set SUPABASE_URL and SUPABASE_KEY environment variables');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

function normalize(t) {
  return (t || '').toLowerCase()
    .replace(/['-]/g, '')
    .trim();
}

// Tokenize text into words for fuzzy matching
function tokenize(t) {
  return normalize(t).split(/[\s_-/]+/).filter(w => w.length > 1);
}

// Score how well a skill matches agent context
function score(skill, agent) {
  let score = 0;
  const agentText = normalize(`${agent.name} ${agent.role} ${agent.title || ''} ${agent.description || ''}`);
  const nameWords = tokenize(agent.name);
  const allAgentWords = tokenize(agentText);
  
  // Skill name match
  const skillName = normalize(`${skill.key} ${skill.name} ${skill.slug}`);
  const skillWords = tokenize(skillName);
  
  // Content match (first 200 chars of markdown as signal)
  const contentSnippet = normalize(skill.markdown?.substring(0, 300) || '');
  const contentWords = tokenize(contentSnippet);
  
  // Exact role match in skill name (high weight)
  if (agent.role && skillName.includes(normalize(agent.role))) {
    score += 50;
  }
  
  // Agent name words in skill name (high weight)
  for (const w of nameWords) {
    if (skillName.includes(w)) score += 15;
  }
  
  // Any agent word in skill name
  for (const w of allAgentWords) {
    if (skillName.includes(w)) score += 5;
  }
  
  // Agent word in skill description
  if (skill.description) {
    const descText = normalize(skill.description);
    for (const w of allAgentWords) {
      if (descText.includes(w)) score += 3;
    }
  }
  
  // Agent word in skill content (first 300 chars)
  for (const w of allAgentWords) {
    if (contentWords.includes(w)) score += 2;
    if (contentSnippet.includes(w)) score += 1;
  }
  
  return score;
}

async function scoreAllSkills() {
  console.log('Fetching agents...');
  const { data: agents } = await supabase
    .from('agents')
    .select('id, name, role, title, company_id, description');
  
  console.log(`Scoring skills for ${agents?.length || 0} agents...\n`);

  for (const agent of agents) {
    const cid = agent.company_id;
    if (!cid) continue;
    
    // Get all skills for this company
    const { data: skills } = await supabase
      .from('company_skills')
      .select('id, key, name, description, markdown, slug')
      .eq('company_id', cid);
    
    if (!skills || skills.length === 0) continue;
    
    console.log(`Agent: ${agent.name} (${agent.role}) - ${skills.length} skills to score`);
    
    // Score every skill
    const scored = skills.map(s => ({
      ...s,
      relevance_score: score(s, agent)
    }));
    
    // Sort by score desc
    scored.sort((a, b) => b.relevance_score - a.relevance_score);
    
    // Print top 5 recommended
    const recommended = scored.slice(0, 5).map(s => 
      `  ${s.relevance_score > 0 ? '✓' : ' '} ${s.relevance_score.toString().padStart(3, ' ')} | ${s.key}`
    ).join('\n');
    
    console.log(`Top 5 recommendations:\n${recommended}\n`);
    
    // Update scores in DB (optional - add a relevance_score column first)
    const sqlUpdates = scored
      .filter(s => s.relevance_score > 0)
      .map(s => `-- ${agent.name}: UPDATE company_skills SET metadata = jsonb_set(COALESCE(metadata,'{}'::jsonb), '{agent_suggestions_${agent.id.slice(0,8)}}', '${s.relevance_score}'::jsonb) WHERE key = '${s.key}';`);
    
    if (sqlUpdates.length > 0) {
      // Write recommendations to metadata
      const suggestions = Object.fromEntries(
        scored.filter(s => s.relevance_score > 0).map(s => [s.key, s.relevance_score])
      );
      
      // For each skill, update metadata with agent suggestion scores
      for (const s of scored.filter(s => s.relevance_score > 0)) {
        const meta = { agent_suggestions: { [agent.id]: s.relevance_score } };
        const { error } = await supabase
          .from('company_skills')
          .update({
            metadata: supabase.rpc('jsonb_merge', { 
              orig: s.metadata || {}, incoming: meta 
            }).code // fallback
          })
          .eq('id', s.id);
        
        // Simpler approach: just set metadata directly
        await supabase
          .from('company_skills')
          .update({
            metadata: { ...s.metadata, agent_suggestions: { [agent.id]: s.relevance_score } }
          })
          .eq('id', s.id);
      }
    }
  }
}

scoreAllSkills().catch(err => {
  console.error(err);
  process.exit(1);
});