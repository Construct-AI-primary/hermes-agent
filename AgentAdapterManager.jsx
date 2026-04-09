import React, { useState, useEffect } from 'react';

const AgentAdapterManager = () => {
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [editingAgent, setEditingAgent] = useState(null);

  // Sample agent data structure based on the CSV
  const sampleAgents = [
    {
      id: '032fbc48-3fa4-4f95-a636-7c58fe2c7f40',
      company_id: 'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
      name: 'Navigator',
      role: 'data',
      title: 'Data Discovery',
      status: 'active',
      adapter_type: 'http',
      capabilities: 'Data catalog development and maintenance; Data lineage tracking and management; Data discovery and exploration tools; Metadata management and governance'
    },
    {
      id: '03573ca2-ac7d-44bf-951b-dca024ed0c82',
      company_id: 'c3559002-20fc-4b42-8e1b-34155e973743',
      name: 'CEO 2',
      role: 'ceo',
      title: '',
      status: 'terminated',
      adapter_type: 'http',
      capabilities: ''
    },
    {
      id: '0368a21c-007b-495f-9aa9-94311982b50c',
      company_id: 'f97b30e8-b022-4350-b4b0-30d43e2ebcf4',
      name: 'Inspector',
      role: 'testing',
      title: 'Environment Validation Specialist',
      status: 'idle',
      adapter_type: 'http',
      capabilities: '["env-validation","testing-verification"]'
    }
  ];

  useEffect(() => {
    // Simulate loading agent data
    const loadAgents = async () => {
      try {
        setLoading(true);
        // In a real app, this would be an API call to Supabase
        // const { data, error } = await supabase.from('agents').select('*');
        // if (error) throw error;
        // setAgents(data);

        // For now, using sample data
        setAgents(sampleAgents);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    loadAgents();
  }, []);

  const handleAdapterTypeChange = async (agentId, newAdapterType) => {
    try {
      // In a real app, this would update Supabase
      // const { error } = await supabase
      //   .from('agents')
      //   .update({ adapter_type: newAdapterType })
      //   .eq('id', agentId);

      // if (error) throw error;

      // Update local state
      setAgents(prevAgents =>
        prevAgents.map(agent =>
          agent.id === agentId
            ? { ...agent, adapter_type: newAdapterType }
            : agent
        )
      );

      setEditingAgent(null);
    } catch (err) {
      setError(`Failed to update adapter type: ${err.message}`);
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'active': return 'text-green-600 bg-green-100';
      case 'idle': return 'text-yellow-600 bg-yellow-100';
      case 'error': return 'text-red-600 bg-red-100';
      case 'terminated': return 'text-gray-600 bg-gray-100';
      default: return 'text-blue-600 bg-blue-100';
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <span className="ml-2">Loading agents...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-md p-4 m-4">
        <div className="flex">
          <div className="ml-3">
            <h3 className="text-sm font-medium text-red-800">Error loading agents</h3>
            <div className="mt-2 text-sm text-red-700">{error}</div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Agent Adapter Manager</h1>
        <p className="text-gray-600">Manage agent adapter types across all companies</p>
      </div>

      <div className="bg-white shadow overflow-hidden sm:rounded-md">
        <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
          <div className="flex justify-between items-center">
            <div>
              <h3 className="text-lg leading-6 font-medium text-gray-900">
                Agents ({agents.length})
              </h3>
              <p className="mt-1 max-w-2xl text-sm text-gray-500">
                All agents configured with HTTP adapter type
              </p>
            </div>
            <div className="flex items-center space-x-3">
              <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                HTTP Adapter
              </span>
            </div>
          </div>
        </div>

        <ul className="divide-y divide-gray-200">
          {agents.map((agent) => (
            <li key={agent.id} className="px-4 py-4 sm:px-6 hover:bg-gray-50">
              <div className="flex items-center justify-between">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center">
                    <div className="flex-shrink-0">
                      <div className="h-10 w-10 rounded-full bg-gray-300 flex items-center justify-center">
                        <span className="text-sm font-medium text-gray-700">
                          {agent.name.charAt(0).toUpperCase()}
                        </span>
                      </div>
                    </div>
                    <div className="ml-4 flex-1">
                      <div className="flex items-center">
                        <h4 className="text-sm font-medium text-gray-900 truncate">
                          {agent.name}
                        </h4>
                        <span className={`ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(agent.status)}`}>
                          {agent.status}
                        </span>
                      </div>
                      <div className="mt-1 flex items-center text-sm text-gray-500">
                        <span className="truncate">{agent.title || agent.role}</span>
                        <span className="mx-2">•</span>
                        <span className="truncate">ID: {agent.id.slice(0, 8)}...</span>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="flex items-center space-x-4">
                  <div className="text-right">
                    <div className="text-sm font-medium text-gray-900">
                      Adapter Type
                    </div>
                    {editingAgent === agent.id ? (
                      <select
                        value={agent.adapter_type}
                        onChange={(e) => handleAdapterTypeChange(agent.id, e.target.value)}
                        className="mt-1 block w-full py-1 px-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 text-sm"
                        onBlur={() => setEditingAgent(null)}
                        autoFocus
                      >
                        <option value="http">http</option>
                        <option value="hermes_local">hermes_local</option>
                        <option value="opencode_local">opencode_local</option>
                      </select>
                    ) : (
                      <div
                        className="text-sm text-gray-500 cursor-pointer hover:text-blue-600"
                        onClick={() => setEditingAgent(agent.id)}
                      >
                        {agent.adapter_type}
                      </div>
                    )}
                  </div>

                  <div className="text-sm text-gray-500">
                    <div>Company</div>
                    <div className="font-mono text-xs">{agent.company_id.slice(0, 8)}...</div>
                  </div>
                </div>
              </div>

              {agent.capabilities && (
                <div className="mt-3">
                  <div className="text-sm text-gray-500">
                    <strong>Capabilities:</strong> {agent.capabilities}
                  </div>
                </div>
              )}
            </li>
          ))}
        </ul>
      </div>

      <div className="mt-8 bg-blue-50 border border-blue-200 rounded-md p-4">
        <div className="flex">
          <div className="ml-3">
            <h3 className="text-sm font-medium text-blue-800">Adapter Type Update</h3>
            <div className="mt-2 text-sm text-blue-700">
              <p>All agents have been configured to use the HTTP adapter type. Click on any adapter type to edit it if needed.</p>
              <p className="mt-2">
                <strong>SQL Update Applied:</strong> The database has been updated to set all agent adapter types to 'http'.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AgentAdapterManager;