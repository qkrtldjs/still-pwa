'use strict';
// Derive the graph without altering stored records or their original tag values.
function thoughtTags(thought){
  const explicit=Array.isArray(thought.tags)?thought.tags:[];
  const inline=[...((thought.title||'')+' '+(thought.content||'')).matchAll(/(?:^|\s)#([\p{L}\p{N}_-]+)/gu)].map(m=>m[1]);
  return [...new Set([...explicit,...inline].map(t=>String(t).trim().replace(/^#+/,'').normalize('NFC')).filter(Boolean))];
}
function buildTagMap(thoughts,tagPositions={}){
  const groups=new Map();
  thoughts.forEach(t=>thoughtTags(t).forEach(tag=>{if(!groups.has(tag))groups.set(tag,[]);groups.get(tag).push(t.id);}));
  const entries=[...groups].sort(([a],[b])=>a.localeCompare(b,'ko'));
  const hubs=entries.map(([tag,members],i)=>{const a=2*Math.PI*i/Math.max(entries.length,1)-Math.PI/2,r=entries.length>1?Math.max(190,entries.length*52):0;return {tag,members,x:Math.cos(a)*r,y:Math.sin(a)*r};});
  const byTag=new Map(hubs.map(h=>[h.tag,h]));
  const nodes=thoughts.map((t,i)=>{
    const tags=thoughtTags(t),attached=tags.map(tag=>byTag.get(tag));let x,y;
    if(attached.length===1){const hub=attached[0],index=hub.members.indexOf(t.id),a=index*2.399963229728653,r=100+Math.sqrt(index)*38;x=hub.x+Math.cos(a)*r;y=hub.y+Math.sin(a)*r;}
    else if(attached.length>1){x=attached.reduce((s,h)=>s+h.x,0)/attached.length+Math.cos(i*2.4)*48;y=attached.reduce((s,h)=>s+h.y,0)/attached.length+Math.sin(i*2.4)*48;}
    else {const untagged=thoughts.filter(t=>!thoughtTags(t).length),index=untagged.findIndex(v=>v.id===t.id);x=(index%4)*165-((Math.min(untagged.length,4)-1)*165)/2;y=hubs.length?Math.max(...hubs.map(h=>h.y))+230+Math.floor(index/4)*100:Math.floor(index/4)*100;}
    return {id:t.id,tags,x:x+(t.tagMapDX||0),y:y+(t.tagMapDY||0)};
  });
  hubs.forEach(h=>{const position=tagPositions&&Object.hasOwn(tagPositions,h.tag)?tagPositions[h.tag]:null;if(Number.isFinite(position?.x))h.x+=position.x;if(Number.isFinite(position?.y))h.y+=position.y;});
  return {hubs,nodes,edges:nodes.flatMap(n=>n.tags.map(tag=>({id:n.id,tag})))};
}
if(typeof module!=='undefined'&&module.exports)module.exports={thoughtTags,buildTagMap};
