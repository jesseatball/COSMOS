/*
# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder
*/

describe('CmdTlmServer Interfaces', () => {
  it('disconnects & connects an interface', () => {
    cy.visit('/cmd-tlm-server/interfaces')
    cy.hideNav()
    cy.get('[data-test=interfaces-table]')
      .contains('INST_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'CONNECTED')
    // Disconnect
    cy.get('[data-test=interfaces-table]')
      .contains('INST_INT')
      .parent()
      .children()
      .eq(1)
      .click()
    cy.get('[data-test=interfaces-table]')
      .contains('INST_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'DISCONNECTED')
    cy.get('[data-test=log-messages]').contains('INST_INT: Disconnect')
    // Connect
    cy.get('[data-test=interfaces-table]')
      .contains('INST_INT')
      .parent()
      .children()
      .eq(1)
      .click()
    cy.get('[data-test=interfaces-table]', { timeout: 10000 })
      .contains('INST_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'CONNECTED')
    cy.get('[data-test=log-messages]').contains('INST_INT: Connection Success')
  })

  it('cancels an inteface from attempting', () => {
    cy.visit('/cmd-tlm-server/interfaces')
    cy.hideNav()
    cy.get('[data-test=interfaces-table]')
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .then((connection) => {
        // Check for DISCONNECTED and if so click connect
        if (connection === 'DISCONNECTED') {
          cy.get('[data-test=interfaces-table]')
            .contains('EXAMPLE_INT')
            .parent()
            .children()
            .eq(1)
            .click()
        }
      })
    cy.get('[data-test=interfaces-table]')
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'ATTEMPTING')
    // Disconnect
    cy.get('[data-test=interfaces-table]')
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(1)
      .click()
    cy.get('[data-test=interfaces-table]')
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'DISCONNECTED')
    cy.get('[data-test=log-messages]').contains('EXAMPLE_INT: Disconnect')
    // Connect
    cy.get('[data-test=interfaces-table]')
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(1)
      .click()
    cy.get('[data-test=interfaces-table]', { timeout: 10000 })
      .contains('EXAMPLE_INT')
      .parent()
      .children()
      .eq(2)
      .invoke('text')
      .should('eq', 'ATTEMPTING')
    cy.get('[data-test=log-messages]').contains('EXAMPLE_INT: Connecting')
  })
})
