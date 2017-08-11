import PropTypes from 'prop-types';
import React from 'react';
import Ajax from '../AjaxWrapper';
import Spinner from './Spinner';

export default class Ticket extends React.Component {
  constructor(props) {
    super(props);
    this.state = { ticket: null }
    this.getTicket(this.props.path);
  }

  getTicket(path) {
    Ajax.req(path, ticketData => {
      this.setState(state => (
        { ticket: ticketData }
      ));
    });
  }

  buildTicket(ticket) {
    return (
      <TicketData
        id={ ticket.id }
        status={ ticket.status }
        priority={ ticket.priority }
        requester_id={ ticket.requester_id }
        description={ ticket.description }
        subject={ ticket.subject }
        created_at={ ticket.created_at }
        updated_at={ ticket.updated_at }
        tags={ ticket.tags }>
      </TicketData>
    );
  }

  render() {
    return (
      <div>
        { this.state.ticket ? this.buildTicket(this.state.ticket) : <Spinner /> }
      </div>
    );
  }
}

class TicketData extends React.Component {

  render () {
    return (
    <div className="ticket-container">
      <div className="ticket-meta meta-top">

        <div title="Ticket ID">
          <span><i className="fa fa-ticket"></i> { this.props.id }</span>
        </div>

        {
          this.props.status &&
          <div className={ 'ticket-status status-' + this.props.status } title="Status">
            { this.props.status }
          </div>
        }

        {
          this.props.priority &&
          <div className={ 'ticket-priority priority-' + this.props.priority } title="Priority">
            { this.props.priority }
          </div>
        }

        <div className="ticket-requester" title="Requester">
          <span><i className="fa fa-user"></i> <a href="#">{ this.props.requester_id }</a></span>
        </div>

      </div>

      <div>

        <div className="ticket-subject" title="Subject">
          <h3>{ this.props.subject }</h3>
        </div>

      </div>

      <div className="ticket-meta meta-bottom">

        {
          this.props.created_at &&
          <div title="Created">
            <span><i className="fa fa-calendar"></i> { this.props.created_at }</span>
          </div>
        }

        {
          this.props.updated_at &&
          <div title="Last updated">
            <span><i className="fa fa-edit"></i> { this.props.updated_at }</span>
          </div>
        }

        {
          this.props.tags && this.props.tags.length > 0 &&
          <div title="Tags">
            <span><i className="fa fa-tags"></i> { this.props.tags.join(', ') }</span>
          </div>
        }

      </div>

      <div>

        <div className="ticket-description">
          { this.props.description }
        </div>

      </div>
    </div>
    );
  }
}
