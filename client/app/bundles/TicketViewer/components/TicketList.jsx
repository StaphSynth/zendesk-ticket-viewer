import PropTypes from 'prop-types';
import React from 'react';
import Ajax from '../AjaxWrapper';
import Spinner from './Spinner';

export default class TicketList extends React.Component {

  constructor(props) {
    super(props);

    this.state = { ticketList: null }
    this.getTickets('/tickets');
  }

  getTickets(path) {
    Ajax.req(path, tickets => {
      this.setState(state => (
        { ticketList: tickets }
      ));
    });
  }

  generateList(tickets) {
    var list = [];

    for(let i = 0; i < tickets.length; i++) {
      list.push(
        <TicketStub
          ticket_id={ tickets[i].id }
          status={ tickets[i].status }
          priority={ tickets[i].priority }
          requester_id={ tickets[i].requester_id }
          subject={ tickets[i].subject }
          created_at={ tickets[i].created_at }
          key={ i }>
        </TicketStub>
      );
    }
    return list;
  }


  render() {
    return (
      <ul className="tickets-list">
        { this.state.ticketList ? this.generateList(this.state.ticketList) : <Spinner /> }
      </ul>
    );
  }
}

class TicketStub extends React.Component {
  render() {
    return (
      <li className="ticket">
        <a href={ '/react_ticket?id=' + this.props.ticket_id }>
          <div className="ticket-gist-container">

            <div>
              <div>
                <span><i className="fa fa-ticket"></i> { this.props.ticket_id }</span>
              </div>

              <div className={ 'ticket-status status-' + this.props.status }>
                { this.props.status }
              </div>

              <div className={ 'ticket-priority priority-' + this.props.priority }>
                { this.props.priority }
              </div>
            </div>

            <div>
              <div className="ticket-subject">{ this.props.subject }</div>
            </div>

            <div>
              <div className="ticket-requester">
                <span><i className="fa fa-user"></i> { this.props.requester_id }</span>
              </div>
            </div>

            <div>
              <div>
                <span><i className="fa fa-calendar</i>"></i> { this.props.created_at }</span>
              </div>
            </div>

          </div>
        </a>
      </li>
    );
  }
}
