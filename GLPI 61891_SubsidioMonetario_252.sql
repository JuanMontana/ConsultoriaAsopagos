--1. Registros subsidioMonetario 
						--252 Total
						--13 Causal explicada
						--239 Causal NULL

SELECT a.*, ('DETALLE EN INFORME_'+a.causal) AS detalle_Causal FROM validacion.job.InformeSubsidioMigracion a
LEFT JOIN (SELECT a.*, b.causal AS detalle_Causal  FROM job.InformeCuentaAdmonMigracion a 
				INNER JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				WHERE b.causal IS NULL) AS B
ON B.casId = a.dsaCuentaAdministradorSubsidio_sabana
WHERE a.causal IS NOT NULL

--2. Regitros subsidioMonetario NULL - Tipo de Beneficiario no valido para tener subsidio Monetario.
SELECT a.*, CASE WHEN a.causal IS NULL AND dsa.benTipoBeneficiario = 'CONYUGE'
					THEN 'grupo de registros de sabana SubsidioMonetario - relacionado a Beneficiario - CONYUGE 
					- se descarta todos los registros relacionados a la misma cuentaAdministradorSubsidio' END AS detalle_Causal
					FROM validacion.job.InformeSubsidioMigracion a
LEFT JOIN (SELECT a.*, b.causal AS detalle_Causal  FROM job.InformeCuentaAdmonMigracion a 
				INNER JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				WHERE b.causal IS NULL) AS B
ON B.casId = a.dsaCuentaAdministradorSubsidio_sabana
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
				ON dsa.dsaCuentaAdministradorSubsidio_sabana = a.dsaCuentaAdministradorSubsidio_sabana
WHERE a.causal IS NULL

/* ******* Case overview **********************
SELECT * FROM validacion.job.InformeSubsidioMigracion a
LEFT JOIN (SELECT a.*, b.causal AS detalle_Causal  FROM job.InformeCuentaAdmonMigracion a 
				INNER JOIN (SELECT dsaCuentaAdministradorSubsidio_sabana, causal FROM 
							job.InformeSubsidioMigracion
							GROUP BY dsaCuentaAdministradorSubsidio_sabana, causal
							) AS b ON a.casId = b.dsaCuentaAdministradorSubsidio_sabana
				WHERE b.causal IS NULL) AS B
ON B.casId = a.dsaCuentaAdministradorSubsidio_sabana
LEFT JOIN (SELECT dsa.dsaId, InfoBen.benTipoBeneficiario
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
				--WHERE InfoBen.benTipoBeneficiario = 'CONYUGE'
				GROUP BY dsa.dsaId, InfoBen.benTipoBeneficiario) AS dsa
				ON dsa.dsaId = a.dsaId
WHERE a.causal IS NULL*/