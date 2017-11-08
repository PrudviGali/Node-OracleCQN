/* Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved. */

/******************************************************************************
 *
 * You may not use the identified files except in compliance with the Apache
 * License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME
 *   api.js
 *
 * DESCRIPTION
 *   Contains the logic for the main application API.
 *
 *****************************************************************************/

var express = require('express');
var oracledb = require('oracledb');
var database = require('./database.js');

function getRouter() {
    var router = express.Router();

    router.route('/employees')
        .get(getEmployees)
        .post(postEmployees);

    router.route('/employees/:employee_id')
        .get(getEmployeesById)
        .put(putEmployeesById)
        .delete(delEmployeesById);

    return router;
}

function getEmployees(req, res, next) {
    database.getPool().getConnection(function(err, connection) {
        if (err) return next(err);

        connection.execute(
            'SELECT employee_id, ' +
            '   first_name, ' +
            '   last_name, ' +
            '   phone_number, ' +
            '   hire_date ' +
            'FROM jsao_employees',
            {},//no binds
            {
                outFormat: oracledb.OBJECT
            },
            function(err, results) {
                if (err) {
                    return connection.release(function() {
                        next(err);
                    });
                }

                connection.release(function(err) {
                    if (err) return next(err);

                    res.send(results);
                });
            }
        );
    });
}

function postEmployees(req, res, next) {
    database.getPool().getConnection(function(err, connection) {
        if (err) return next(err);

        connection.execute(
            'INSERT INTO jsao_employees (' +
            '   first_name, ' +
            '   last_name, ' +
            '   phone_number, ' +
            '   hire_date ' +
            ') VALUES ( ' +
            '   :FIRST_NAME, ' +
            '   :LAST_NAME, ' +
            '   :PHONE_NUMBER, ' +
            '   :HIRE_DATE ' +
            ')',
            {
                FIRST_NAME: {
                    val: req.body.FIRST_NAME
                },
                LAST_NAME: {
                    val: req.body.LAST_NAME
                },
                PHONE_NUMBER: {
                    val: req.body.PHONE_NUMBER
                },
                HIRE_DATE: {
                    val: new Date(req.body.HIRE_DATE)
                }
            },
            {
                isAutoCommit: true
            },
            function(err, results) {
                if (err) {
                    return connection.release(function() {
                        next(err);
                    });
                }

                connection.release(function(err) {
                    if (err) return next(err);

                    res.send(results);
                });
            }
        );
    });
}

function getEmployeesById(req, res, next) {
    database.getPool().getConnection(function(err, connection) {
        if (err) return next(err);

        connection.execute(
            'SELECT employee_id, ' +
            '   first_name, ' +
            '   last_name, ' +
            '   phone_number, ' +
            '   hire_date ' +
            'FROM jsao_employees ' +
            'WHERE employee_id = :EMPLOYEE_ID',
            {
                EMPLOYEE_ID: req.params.employee_id
            },
            {
                outFormat: oracledb.OBJECT
            },
            function(err, results) {
                if (err) {
                    return connection.release(function() {
                        next(err);
                    });
                }

                connection.release(function(err) {
                    if (err) return next(err);

                    res.send(results);
                });
            }
        );
    });
}

function putEmployeesById(req, res, next) {
    database.getPool().getConnection(function(err, connection) {
        if (err) return next(err);

        connection.execute(
            'UPDATE jsao_employees ' +
            'SET first_name = :FIRST_NAME, ' +
            '   last_name = :LAST_NAME, ' +
            '   phone_number = :PHONE_NUMBER, ' +
            '   hire_date = :HIRE_DATE ' +
            'WHERE employee_id = :EMPLOYEE_ID',
            {
                EMPLOYEE_ID: {
                    val: req.body.EMPLOYEE_ID,
                    type: oracledb.NUMBER
                },
                FIRST_NAME: {
                    val: req.body.FIRST_NAME
                },
                LAST_NAME: {
                    val: req.body.LAST_NAME
                },
                PHONE_NUMBER: {
                    val: req.body.PHONE_NUMBER
                },
                HIRE_DATE: {
                    val: new Date(req.body.HIRE_DATE)
                }
            },
            {
                isAutoCommit: true
            },
            function(err, results) {
                if (err) {
                    return connection.release(function() {
                        next(err);
                    });
                }

                connection.release(function(err) {
                    if (err) return next(err);

                    res.send(results);
                });
            }
        );
    });
}

function delEmployeesById(req, res, next) {
    database.getPool().getConnection(function(err, connection) {
        if (err) return next(err);

        connection.execute(
            'DELETE FROM jsao_employees WHERE employee_id = :EMPLOYEE_ID',
            {
                EMPLOYEE_ID: req.params.employee_id
            },
            {
                isAutoCommit: true
            },
            function(err, results) {
                if (err) {
                    return connection.release(function() {
                        next(err);
                    });
                }

                connection.release(function(err) {
                    if (err) return next(err);

                    res.send(results);
                });
            }
        );
    });
}

module.exports.getRouter = getRouter;