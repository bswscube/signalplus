var ContentPanel = React.createClass({
  getInitialState: function() {
    return {
      sidebarMenus: [
        { id: 1, contentId: 'edit', active: true },
        { id: 2, contentId: 'promote', active: false },
        { id: 3, contentId: 'preview', active: false },
        { id: 4, contentId: 'activity', active: false },
      ]
    }
  },

  handleSideBar: function(menu) {
    var newMenus = this.state.sidebarMenus.map(function(m) {
      if (m.contentId == menu) {
        m.active = true
      } else {
        m.active = false
      }
      return m
    });
    this.setState({sidebarMenus: newMenus})
  },

  getSignal: function() {
    if (typeof this.props.editSignal !== 'undefined') {
      return ({ edit: this.props.editSignal })
    } else if (typeof this.props.templateType !== 'undefined') {
      return ({ type: this.props.templateType })
    }
  },

  render: function() {
    var signal = this.getSignal();

    return (
      <div className='content-panel'>
          <Sidebar 
            menus={this.state.sidebarMenus} 
            handleClick={this.handleSideBar} 
            signalType={this.signalState} 
          />
          <MenuContent 
            menus={this.state.sidebarMenus} 
            signal={signal}
          />
      </div>
    );
  }
});



