--1. Registros cuentaAdministradorSubsidio_Migracion con descartes de SubsidioMonetario en malla
				SELECT a.*, 'Sus registros relacionados con la sabana SubsidioMonetario tienen descartes por malla reportados en InformeSubsidioMalla' AS detalle_Causal
				FROM job.InformeCuentaAdmonMigracion a 
				LEFT JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				LEFT JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana FROM validacion.job.InformeSubsidioMalla
							GROUP BY dsaCuentaAdministradorSubsidio_sabana) AS c
				ON c.dsaCuentaAdministradorSubsidio_sabana = a.casId
				WHERE b.dsaCuentaAdministradorSubsidio_sabana IS NULL

--2. Registros cuentaAdministradorSubsidio_Migracion con descartes relacionados de SubsidioMonetario en Migración no NULL
				SELECT a.*, b.causal AS detalle_Causal  FROM job.InformeCuentaAdmonMigracion a 
				INNER JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				WHERE b.causal IS NOT NULL;

--3. Registros cuentaAdministradorSubsidio_Migracion con descartes relacionados de SubsidioMonetario en Migración NULL
--Motivo - Tipo de beneficiario no valido para tener subsidio monetario.
				SELECT a.*, CASE WHEN mgrMigracion.casIdMgrSabana IS NULL AND dsa.benTipoBeneficiario = 'CONYUGE'
					THEN 'registro de sabana SubsidioMonetario - relacionado a Beneficiario - CONYUGE' END AS detalle_Causal
				FROM job.InformeCuentaAdmonMigracion a 
				INNER JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				LEFT JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana AS casIdPro
							FROM validacion.pro.SubsidioMonetario 
							GROUP BY dsaCuentaAdministradorSubsidio_sabana) AS casIdPro
				ON casIdPro.casIdPro = a.casId
				LEFT JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana AS casIdMgrSabana
								FROM subsidio.mgr.DetalleSubsidioAsignado_sabana
								GROUP BY dsaCuentaAdministradorSubsidio_sabana) AS mgrSabana
				ON mgrSabana.casIdMgrSabana = a.casId
				LEFT JOIN (SELECT a.dsaCuentaAdministradorSubsidio_sabana AS casIdMgrSabana
								FROM subsidio.mgr.DetalleSubsidioAsignado_sabana a
								INNER JOIN subsidio.mgr.DetalleSubsidioAsignado b
								ON b.idSabana = a.dsaId
								GROUP BY dsaCuentaAdministradorSubsidio_sabana) AS mgrMigracion
				ON mgrMigracion.casIdMgrSabana = a.casId
				--dsa
				LEFT JOIN (SELECT dsa.dsaCuentaAdministradorSubsidio_sabana, InfoBen.benTipoBeneficiario
				FROM subsidio.mgr.temp dsa
				--CondicionEmpleador
				LEFT JOIN Subsidio.staging.CondicionPersona cpeEmp ON cpeEmp.cpeId = dsa.cpeEmp
				LEFT JOIN Subsidio.staging.CondicionEmpleador cem ON cpeEmp.cpeId = cem.cemCondicionPersona AND dsa.dsaPeriodoLiquidado = cem.cemPeriodo
				--CondicionTrabajador
				LEFT JOIN Subsidio.staging.CondicionPersona cpeTra ON cpeTra.cpeId = dsa.cpeTra
				LEFT JOIN Subsidio.staging.CondicionTrabajador ctr ON cpeTra.cpeId = ctr.ctrCondicionPersona AND dsa.dsaPeriodoLiquidado = ctr.ctrPeriodo
				--CondicionTrabajador
				LEFT JOIN Subsidio.staging.CondicionPersona cpeBen ON cpeBen.cpeId = dsa.cpeBen
				LEFT JOIN Subsidio.staging.CondicionBeneficiario cbe ON cpeBen.cpeId = cbe.cbeCondicionPersona AND dsa.dsaPeriodoLiquidado = cbe.cbePeriodo
				--CondicionEmpleadorTrabajador
				LEFT JOIN Subsidio.staging.CondicionEmpleadorTrabajador cet ON cet.cetCondicionEmpleador = cem.cemId AND cet.cetCondicionTrabajador = ctr.ctrId
				--CondicionAfiliadoPplBeneficiario
				LEFT JOIN Subsidio.staging.CondicionAfiliadoPplBeneficiario cab ON cab.cabCondicionTrabajador = ctr.ctrId AND cab.cabCondicionBeneficiario = cbe.cbeId
				--Tipo Beneficiario
				LEFT JOIN (SELECT ben.benPersona, ben.benId, ben.benTipoBeneficiario, afi.afiPersona, afi.afiId
							FROM subsidio.dbo.Afiliado afi
							INNER JOIN subsidio.dbo.Beneficiario ben ON ben.benAfiliado = afi.afiId) AS InfoBen
				ON InfoBen.benPersona = cpeBen.cpePersona AND InfoBen.afiPersona = cpeTra.cpePersona
				WHERE InfoBen.benTipoBeneficiario = 'CONYUGE'
				GROUP BY dsa.dsaCuentaAdministradorSubsidio_sabana, InfoBen.benTipoBeneficiario) AS dsa
				ON dsa.dsaCuentaAdministradorSubsidio_sabana = a.casId
				WHERE b.causal IS NULL;